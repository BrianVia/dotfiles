#!/usr/bin/env bash
set -euo pipefail

# Compute UTC window for last 24 hours
if date -u -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ" >/dev/null 2>&1; then
  # GNU date (Linux)
  START=$(date -u -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
else
  # BSD date (macOS)
  START=$(date -u -v-24H +"%Y-%m-%dT%H:%M:%SZ")
fi
END=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

read -r -d '' PROMPT <<EOF || true
Use the Linear MCP server (named "linear") only.
Task: Summarize all work I completed in the last 24 hours.

Steps:
1) Query Linear for issues/tasks updated between ${START} and ${END} (UTC), assigned to me ("me").
2) Group by Team and Project. For each item include: key, title, state, updatedAt, and construct a Linear URL.
3) Output a concise Markdown report:
   - "24h Summary" headline with counts (# completed, # in progress, # created, etc.)
   - Sections per Team → Project with bullet points
   - Final "What changed" bullets (themes, blockers cleared, follow-ups)

Important Context:
- Issues in states like "Ready to Smoke Test", "QA Ready", or similar testing/review states should be treated as DEV COMPLETE.
- These represent work I've finished from a development perspective, even though they're awaiting QA/testing.
- Count and present them as completed development work, not as in-progress items.

Constraints:
- Use only the "linear" MCP tools; do not browse the web or run shell commands.
- If authentication is required, stop and report the needed action.
EOF

# Fire one-shot request
claude -p "$PROMPT" \
  --dangerously-skip-permissions \
  --max-turns 4 \
  --output-format text
