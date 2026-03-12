// Ralph Loop Agent - Iterative AI development loops using Claude Agent SDK
// Based on Geoffrey Huntley's Ralph Wiggum technique

export { RalphLoopAgent } from "./agent.js";
export type { RalphConfig, LoopOptions, LoopResult, LoopState } from "./agent.js";

export {
  iterationCountIs,
  tokenCountIs,
  costIs,
  durationIs,
  outputContains,
  allOf,
  anyOf,
} from "./conditions.js";
export type { StopCondition } from "./conditions.js";

export { readFile, writeFile, execute, fileExists, glob } from "./tools.js";
export type { ToolDefinition } from "./tools.js";

export { TokenTracker } from "./tracker.js";
