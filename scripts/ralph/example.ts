#!/usr/bin/env bun
// Example: Migrate from Jest to Vitest using Ralph Loop

import {
  RalphLoopAgent,
  iterationCountIs,
  tokenCountIs,
  costIs,
  readFile,
  writeFile,
  execute,
  fileExists,
  glob,
} from "./index.js";
import { checkFileExists, noFilesMatch } from "./tools.js";

const agent = new RalphLoopAgent({
  model: "claude-opus-4-5-20250514",
  instructions: `
    You are migrating a codebase from Jest to Vitest.

    Work systematically:
    1. Update package.json (remove jest, add vitest)
    2. Create vitest.config.ts
    3. Update imports in all test files (replace @jest with vitest equivalents)
    4. Run 'pnpm test' and fix any failures

    You are DONE when all tests pass with vitest.
  `,
  tools: { readFile, writeFile, execute, fileExists, glob },
  stopWhen: [
    iterationCountIs(50),
    tokenCountIs(500_000),
    costIs(5.0),
  ],
  verifyCompletion: async () => {
    const { handler } = execute;
    const { exitCode } = await handler({ command: "pnpm test" });

    if (exitCode !== 0) {
      return { complete: false, reason: "Tests failing" };
    }

    const checks = await Promise.all([
      checkFileExists("vitest.config.ts"),
      checkFileExists("jest.config.js").then((exists) => !exists),
      noFilesMatch("**/*.test.ts", /from ["']@jest/),
    ]);

    const complete = checks.every(Boolean);
    return {
      complete,
      reason: complete
        ? "All tests pass with vitest"
        : "Migration incomplete",
    };
  },
  verbose: true,
});

// Run the loop
const result = await agent.loop({
  prompt: "Migrate all tests from Jest to Vitest. Start by examining the current test setup.",
});

console.log("\n=== Ralph Loop Complete ===");
console.log(`Success: ${result.success}`);
console.log(`Iterations: ${result.iterations}`);
console.log(`Cost: $${result.totalCostUsd.toFixed(4)}`);
console.log(`Duration: ${(result.durationMs / 1000).toFixed(1)}s`);
console.log(`Stop reason: ${result.stopReason}`);
if (result.error) {
  console.log(`Error: ${result.error.message}`);
}
