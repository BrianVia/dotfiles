// Sandbox tools for Ralph loops
// These wrap common operations for use in agent tool definitions

import { spawn } from "child_process";
import { readFile as fsReadFile, writeFile as fsWriteFile, access } from "fs/promises";
import { glob as fastGlob } from "fast-glob";
import { constants } from "fs";

export interface ToolDefinition<TInput = unknown, TOutput = unknown> {
  description: string;
  schema: Record<string, unknown>;
  handler: (input: TInput) => Promise<TOutput>;
}

/**
 * Read a file's contents
 */
export const readFile: ToolDefinition<{ path: string }, { content: string }> = {
  description: "Read the contents of a file",
  schema: {
    type: "object",
    properties: {
      path: { type: "string", description: "File path to read" },
    },
    required: ["path"],
  },
  handler: async ({ path }) => {
    const content = await fsReadFile(path, "utf-8");
    return { content };
  },
};

/**
 * Write content to a file
 */
export const writeFile: ToolDefinition<{ path: string; content: string }, { success: boolean }> = {
  description: "Write content to a file (creates or overwrites)",
  schema: {
    type: "object",
    properties: {
      path: { type: "string", description: "File path to write" },
      content: { type: "string", description: "Content to write" },
    },
    required: ["path", "content"],
  },
  handler: async ({ path, content }) => {
    await fsWriteFile(path, content, "utf-8");
    return { success: true };
  },
};

/**
 * Execute a shell command
 */
export const execute: ToolDefinition<
  { command: string; cwd?: string; timeout?: number },
  { stdout: string; stderr: string; exitCode: number }
> = {
  description: "Execute a shell command",
  schema: {
    type: "object",
    properties: {
      command: { type: "string", description: "Command to execute" },
      cwd: { type: "string", description: "Working directory (optional)" },
      timeout: { type: "number", description: "Timeout in ms (default: 120000)" },
    },
    required: ["command"],
  },
  handler: async ({ command, cwd, timeout = 120000 }) => {
    return new Promise((resolve) => {
      const proc = spawn(command, {
        shell: true,
        cwd: cwd ?? process.cwd(),
        timeout,
      });

      let stdout = "";
      let stderr = "";

      proc.stdout?.on("data", (data) => (stdout += data.toString()));
      proc.stderr?.on("data", (data) => (stderr += data.toString()));

      proc.on("close", (code) => {
        resolve({
          stdout: stdout.trim(),
          stderr: stderr.trim(),
          exitCode: code ?? 1,
        });
      });

      proc.on("error", (err) => {
        resolve({
          stdout: "",
          stderr: err.message,
          exitCode: 1,
        });
      });
    });
  },
};

/**
 * Check if a file exists
 */
export const fileExists: ToolDefinition<{ path: string }, { exists: boolean }> = {
  description: "Check if a file or directory exists",
  schema: {
    type: "object",
    properties: {
      path: { type: "string", description: "Path to check" },
    },
    required: ["path"],
  },
  handler: async ({ path }) => {
    try {
      await access(path, constants.F_OK);
      return { exists: true };
    } catch {
      return { exists: false };
    }
  },
};

/**
 * Find files matching a glob pattern
 */
export const glob: ToolDefinition<{ pattern: string; cwd?: string }, { files: string[] }> = {
  description: "Find files matching a glob pattern",
  schema: {
    type: "object",
    properties: {
      pattern: { type: "string", description: "Glob pattern (e.g., '**/*.ts')" },
      cwd: { type: "string", description: "Base directory (optional)" },
    },
    required: ["pattern"],
  },
  handler: async ({ pattern, cwd }) => {
    const files = await fastGlob(pattern, {
      cwd: cwd ?? process.cwd(),
      onlyFiles: true,
    });
    return { files };
  },
};

/**
 * Helper to check file existence (non-tool version for verifyCompletion)
 */
export async function checkFileExists(path: string): Promise<boolean> {
  try {
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

/**
 * Helper to check no files match a pattern with content (for verifyCompletion)
 */
export async function noFilesMatch(pattern: string, contentRegex: RegExp): Promise<boolean> {
  const files = await fastGlob(pattern, { onlyFiles: true });
  for (const file of files) {
    const content = await fsReadFile(file, "utf-8");
    if (contentRegex.test(content)) {
      return false;
    }
  }
  return true;
}
