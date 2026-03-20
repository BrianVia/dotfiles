#!/bin/bash
# Intercepts `gh pr create` calls that lack a problem statement and redirects Claude
# to use the /create-pr skill. Allows through calls that already have a ## Problem
# section (i.e., calls originating from the skill itself).

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only intercept gh pr create commands
if echo "$COMMAND" | grep -q 'gh pr create'; then
  # Allow if the command already contains a Problem section (came from the skill)
  if echo "$COMMAND" | grep -q '## Problem'; then
    exit 0
  fi

  # Block bare gh pr create — redirect to the skill
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: Do not use gh pr create directly. Use the /create-pr skill instead — it ensures PR descriptions include a problem statement explaining WHY changes were made, not just WHAT changed. Invoke the create-pr skill now."
    }
  }'
  exit 0
fi

# Allow everything else
exit 0
