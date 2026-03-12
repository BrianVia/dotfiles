// Token and cost tracking for Ralph loops

export interface Usage {
  inputTokens: number;
  outputTokens: number;
  cacheCreationTokens: number;
  cacheReadTokens: number;
}

export interface StepUsage {
  messageId: string;
  iteration: number;
  usage: Usage;
  costUsd: number;
}

// Pricing per 1M tokens (as of Jan 2025)
const PRICING = {
  "claude-opus-4-5-20250514": { input: 15.0, output: 75.0, cacheRead: 1.5 },
  "claude-sonnet-4-20250514": { input: 3.0, output: 15.0, cacheRead: 0.3 },
  "claude-3-5-sonnet-20241022": { input: 3.0, output: 15.0, cacheRead: 0.3 },
  "claude-3-5-haiku-20241022": { input: 0.8, output: 4.0, cacheRead: 0.08 },
} as const;

type ModelName = keyof typeof PRICING;

export class TokenTracker {
  private processedIds = new Set<string>();
  private steps: StepUsage[] = [];
  private model: ModelName;
  private currentIteration = 0;

  constructor(model: string) {
    this.model = (model in PRICING ? model : "claude-opus-4-5-20250514") as ModelName;
  }

  setIteration(iteration: number) {
    this.currentIteration = iteration;
  }

  track(messageId: string, rawUsage: Record<string, number>) {
    // Deduplicate by message ID
    if (this.processedIds.has(messageId)) return;
    this.processedIds.add(messageId);

    const usage: Usage = {
      inputTokens: rawUsage.input_tokens ?? 0,
      outputTokens: rawUsage.output_tokens ?? 0,
      cacheCreationTokens: rawUsage.cache_creation_input_tokens ?? 0,
      cacheReadTokens: rawUsage.cache_read_input_tokens ?? 0,
    };

    const costUsd = this.calculateCost(usage);

    this.steps.push({
      messageId,
      iteration: this.currentIteration,
      usage,
      costUsd,
    });
  }

  private calculateCost(usage: Usage): number {
    const rates = PRICING[this.model];
    const inputCost = (usage.inputTokens / 1_000_000) * rates.input;
    const outputCost = (usage.outputTokens / 1_000_000) * rates.output;
    const cacheCost = (usage.cacheReadTokens / 1_000_000) * rates.cacheRead;
    return inputCost + outputCost + cacheCost;
  }

  getUsage(): Usage {
    return this.steps.reduce(
      (acc, step) => ({
        inputTokens: acc.inputTokens + step.usage.inputTokens,
        outputTokens: acc.outputTokens + step.usage.outputTokens,
        cacheCreationTokens: acc.cacheCreationTokens + step.usage.cacheCreationTokens,
        cacheReadTokens: acc.cacheReadTokens + step.usage.cacheReadTokens,
      }),
      { inputTokens: 0, outputTokens: 0, cacheCreationTokens: 0, cacheReadTokens: 0 }
    );
  }

  getTotalCost(): number {
    return this.steps.reduce((sum, step) => sum + step.costUsd, 0);
  }

  getSteps(): StepUsage[] {
    return [...this.steps];
  }

  getSummary(): string {
    const usage = this.getUsage();
    const cost = this.getTotalCost();
    const totalTokens = usage.inputTokens + usage.outputTokens;
    return `${totalTokens.toLocaleString()} tokens ($${cost.toFixed(4)})`;
  }
}
