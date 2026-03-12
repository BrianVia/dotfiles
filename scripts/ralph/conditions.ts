// Stop conditions for Ralph loops

import type { LoopState } from "./agent.js";

export type StopCondition = (state: LoopState) => boolean;

/**
 * Stop after N iterations
 */
export function iterationCountIs(maxCount: number): StopCondition {
  return (state) => state.iterations >= maxCount;
}

/**
 * Stop after N total tokens (input + output)
 */
export function tokenCountIs(maxTokens: number): StopCondition {
  return (state) => {
    const total = state.usage.inputTokens + state.usage.outputTokens;
    return total >= maxTokens;
  };
}

/**
 * Stop after spending $X USD
 */
export function costIs(maxCost: number): StopCondition {
  return (state) => state.totalCostUsd >= maxCost;
}

/**
 * Stop after N milliseconds
 */
export function durationIs(maxMs: number): StopCondition {
  return (state) => state.durationMs >= maxMs;
}

/**
 * Stop if assistant output contains specific text
 */
export function outputContains(text: string): StopCondition {
  return (state) => state.lastOutput?.includes(text) ?? false;
}

/**
 * Combine conditions with AND logic
 */
export function allOf(...conditions: StopCondition[]): StopCondition {
  return (state) => conditions.every((c) => c(state));
}

/**
 * Combine conditions with OR logic (default behavior of stopWhen array)
 */
export function anyOf(...conditions: StopCondition[]): StopCondition {
  return (state) => conditions.some((c) => c(state));
}
