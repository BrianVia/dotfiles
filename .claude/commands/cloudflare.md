---
description: Comprehensive Cloudflare platform skill covering Workers, Pages, storage (KV, D1, R2), AI (Workers AI, Vectorize, Agents SDK), networking (Tunnel, Spectrum), security (WAF, DDoS), and infrastructure-as-code (Terraform, Pulumi). Use for any Cloudflare development task.
---

Load the Cloudflare platform skill and help with any Cloudflare development task.

## Workflow

### Step 1: Check for --update-skill flag

If $ARGUMENTS contains `--update-skill`:

1. Run the update command:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/dmmulroy/cloudflare-skill/main/install.sh | bash -s -- --global
   ```

2. Then copy to Claude Code's skill directory:
   ```bash
   cp -r ~/.config/opencode/skill/cloudflare ~/.claude/skills/cloudflare
   cp ~/.config/opencode/command/cloudflare.md ~/.claude/commands/cloudflare.md
   ```

3. Output success message and stop.

### Step 2: Load cloudflare skill

Read the main skill manifest:
```
~/.claude/skills/cloudflare/SKILL.md
```

### Step 3: Identify task type from user request

Analyze $ARGUMENTS to determine:
- **Product(s) needed** (Workers, D1, R2, Durable Objects, etc.)
- **Task type** (new project setup, feature implementation, debugging, config)

Use decision trees in SKILL.md to select correct product.

### Step 4: Read relevant reference files

Based on task type, read from `~/.claude/skills/cloudflare/references/<product>/`:

| Task | Files to Read |
|------|---------------|
| New project | `README.md` + `configuration.md` |
| Implement feature | `README.md` + `api.md` + `patterns.md` |
| Debug/troubleshoot | `gotchas.md` |
| All-in-one (monolithic) | `SKILL.md` |

### Step 5: Execute task

Apply Cloudflare-specific patterns and APIs from references to complete the user's request.

### Step 6: Summarize

```
=== Cloudflare Task Complete ===

Product(s): <products used>
Files referenced: <reference files consulted>

<brief summary of what was done>
```

<user-request>
$ARGUMENTS
</user-request>
