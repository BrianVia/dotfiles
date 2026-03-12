// RalphLoopAgent - Main agent class for iterative development loops

import Anthropic from "@anthropic-ai/sdk";
import { readFileSync, existsSync } from "fs";
import { homedir } from "os";
import { join } from "path";

function getApiKey(): string | undefined {
  // 1. Environment variable (standard)
  if (process.env.ANTHROPIC_API_KEY) {
    return process.env.ANTHROPIC_API_KEY;
  }

  // 2. Check ~/.anthropic/api_key
  const anthropicKeyFile = join(homedir(), ".anthropic", "api_key");
  if (existsSync(anthropicKeyFile)) {
    return readFileSync(anthropicKeyFile, "utf-8").trim();
  }

  // 3. Check ~/.config/anthropic/api_key
  const configKeyFile = join(homedir(), ".config", "anthropic", "api_key");
  if (existsSync(configKeyFile)) {
    return readFileSync(configKeyFile, "utf-8").trim();
  }

  return undefined;
}
import type { StopCondition } from "./conditions.js";
import type { ToolDefinition } from "./tools.js";
import { TokenTracker, type Usage } from "./tracker.js";

export interface LoopState {
  iterations: number;
  usage: Usage;
  totalCostUsd: number;
  durationMs: number;
  lastOutput?: string;
}

export interface LoopResult {
  success: boolean;
  iterations: number;
  totalCostUsd: number;
  usage: Usage;
  durationMs: number;
  lastOutput: string;
  stopReason: "completion" | "condition" | "error";
  error?: Error;
}

export interface LoopOptions {
  prompt: string;
  /** Override max iterations for this run */
  maxIterations?: number;
}

export interface RalphConfig {
  /** Model to use (default: claude-sonnet-4-20250514) */
  model?: string;
  /** System instructions for the agent */
  instructions: string;
  /** Tools available to the agent */
  tools: Record<string, ToolDefinition>;
  /** Stop conditions - loop stops when ANY condition is true */
  stopWhen: StopCondition[];
  /** Optional verification function - returns true if task is complete */
  verifyCompletion?: () => Promise<{ complete: boolean; reason?: string }>;
  /** Working directory for tool execution */
  cwd?: string;
  /** Max tokens for response (default: 8192) */
  maxTokens?: number;
  /** Enable verbose logging */
  verbose?: boolean;
}

type Tool = Anthropic.Messages.Tool;
type ToolUseBlock = Anthropic.Messages.ToolUseBlock;
type ToolResultBlockParam = Anthropic.Messages.ToolResultBlockParam;
type MessageParam = Anthropic.Messages.MessageParam;

export class RalphLoopAgent {
  private client: Anthropic;
  private config: Required<Omit<RalphConfig, "verifyCompletion">> & {
    verifyCompletion?: RalphConfig["verifyCompletion"];
  };

  constructor(config: RalphConfig) {
    const apiKey = getApiKey();
    this.client = new Anthropic(apiKey ? { apiKey } : undefined);
    this.config = {
      model: config.model ?? "claude-opus-4-5-20250514",
      instructions: config.instructions,
      tools: config.tools,
      stopWhen: config.stopWhen,
      verifyCompletion: config.verifyCompletion,
      cwd: config.cwd ?? process.cwd(),
      maxTokens: config.maxTokens ?? 8192,
      verbose: config.verbose ?? false,
    };
  }

  private log(message: string) {
    if (this.config.verbose) {
      console.log(`[ralph] ${message}`);
    }
  }

  private buildTools(): Tool[] {
    return Object.entries(this.config.tools).map(([name, def]) => ({
      name,
      description: def.description,
      input_schema: def.schema as Tool["input_schema"],
    }));
  }

  private async executeTool(name: string, input: unknown): Promise<string> {
    const tool = this.config.tools[name];
    if (!tool) {
      return JSON.stringify({ error: `Unknown tool: ${name}` });
    }

    try {
      const result = await tool.handler(input);
      return JSON.stringify(result);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return JSON.stringify({ error: message });
    }
  }

  async loop(options: LoopOptions): Promise<LoopResult> {
    const startTime = Date.now();
    const tracker = new TokenTracker(this.config.model);
    const tools = this.buildTools();

    let iterations = 0;
    let lastOutput = "";
    let messages: MessageParam[] = [];

    // Initial user message with the prompt
    const systemPrompt = `${this.config.instructions}

IMPORTANT: You are in an iterative loop. After each response, your work will be evaluated.
When you believe you have completed the task, clearly state that you are done.
Work systematically and make progress each iteration.`;

    this.log(`Starting loop with prompt: ${options.prompt.slice(0, 100)}...`);

    try {
      while (true) {
        iterations++;
        tracker.setIteration(iterations);
        this.log(`\n=== Iteration ${iterations} ===`);

        // Build messages for this turn
        if (messages.length === 0) {
          messages = [{ role: "user", content: options.prompt }];
        }

        // Call the API
        const response = await this.client.messages.create({
          model: this.config.model,
          max_tokens: this.config.maxTokens,
          system: systemPrompt,
          tools,
          messages,
        });

        // Track usage
        if (response.usage) {
          tracker.track(response.id, response.usage as unknown as Record<string, number>);
        }

        // Extract text content
        const textBlocks = response.content.filter((b) => b.type === "text");
        lastOutput = textBlocks.map((b) => b.text).join("\n");

        if (lastOutput) {
          this.log(`Output: ${lastOutput.slice(0, 200)}...`);
        }

        // Check for tool use
        const toolUses = response.content.filter((b): b is ToolUseBlock => b.type === "tool_use");

        if (toolUses.length > 0) {
          this.log(`Tool calls: ${toolUses.map((t) => t.name).join(", ")}`);

          // Execute tools
          const toolResults: ToolResultBlockParam[] = await Promise.all(
            toolUses.map(async (toolUse) => ({
              type: "tool_result" as const,
              tool_use_id: toolUse.id,
              content: await this.executeTool(toolUse.name, toolUse.input),
            }))
          );

          // Add assistant response and tool results to messages
          messages.push({ role: "assistant", content: response.content });
          messages.push({ role: "user", content: toolResults });

          // Continue to next iteration (tool use means more work to do)
          continue;
        }

        // No tool use - check stop conditions
        const state: LoopState = {
          iterations,
          usage: tracker.getUsage(),
          totalCostUsd: tracker.getTotalCost(),
          durationMs: Date.now() - startTime,
          lastOutput,
        };

        // Check explicit stop conditions
        const conditionMet = this.config.stopWhen.some((cond) => cond(state));
        if (conditionMet) {
          this.log("Stop condition met");
          return {
            success: true,
            iterations,
            totalCostUsd: tracker.getTotalCost(),
            usage: tracker.getUsage(),
            durationMs: Date.now() - startTime,
            lastOutput,
            stopReason: "condition",
          };
        }

        // Check verification function
        if (this.config.verifyCompletion) {
          const verification = await this.config.verifyCompletion();
          if (verification.complete) {
            this.log(`Verification passed: ${verification.reason ?? "complete"}`);
            return {
              success: true,
              iterations,
              totalCostUsd: tracker.getTotalCost(),
              usage: tracker.getUsage(),
              durationMs: Date.now() - startTime,
              lastOutput,
              stopReason: "completion",
            };
          }
          this.log(`Verification failed: ${verification.reason ?? "not complete"}`);
        }

        // Check max iterations from options
        if (options.maxIterations && iterations >= options.maxIterations) {
          this.log(`Max iterations (${options.maxIterations}) reached`);
          return {
            success: false,
            iterations,
            totalCostUsd: tracker.getTotalCost(),
            usage: tracker.getUsage(),
            durationMs: Date.now() - startTime,
            lastOutput,
            stopReason: "condition",
          };
        }

        // Continue loop - add assistant response and continue prompt
        messages.push({ role: "assistant", content: response.content });
        messages.push({
          role: "user",
          content: `Continue working on the task. Iteration ${iterations + 1}.
Previous progress has been saved. What's the next step?`,
        });

        // Emit progress
        console.log(
          `[ralph] Iteration ${iterations}: ${tracker.getSummary()} | ${((Date.now() - startTime) / 1000).toFixed(1)}s`
        );
      }
    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      this.log(`Error: ${err.message}`);
      return {
        success: false,
        iterations,
        totalCostUsd: tracker.getTotalCost(),
        usage: tracker.getUsage(),
        durationMs: Date.now() - startTime,
        lastOutput,
        stopReason: "error",
        error: err,
      };
    }
  }
}
