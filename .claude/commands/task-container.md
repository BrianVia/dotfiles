# Task Container Skill

Start a Claude container task on the appropriate server instance.

## Instance Selection Logic

Determine which instance to use based on the current working directory:

**Work Instance** (use if ANY of these match):
- Current directory is under `~/Development/Dfinitiv/`
- Current directory name contains `mojo-` or `savvy-`
- Project name in path contains `mojo-` or `savvy-`

**Home Instance** (use for everything else - personal projects)

## Instance Configuration

| Instance | Base URL | API Key |
|----------|----------|---------|
| Work | `https://claudepod-work.flatmeadow.com/api` | `mojo-savvy` |
| Home | `https://claudepod-home.flatmeadow.com/api` | `briguy` |

## Instructions

1. First, determine which instance to use based on the current working directory (`pwd`)
2. Ask the user what task they want to run on the container if not provided as an argument
3. Create the container with the task prompt

### Create Container Command

```bash
# Work instance
curl -s -X POST "https://claudepod-work.flatmeadow.com/api/containers" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: mojo-savvy" \
  -d '{
    "claudePrompt": "<TASK_DESCRIPTION>",
    "useDefaults": true
  }'

# Home instance
curl -s -X POST "https://claudepod-home.flatmeadow.com/api/containers" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: briguy" \
  -d '{
    "claudePrompt": "<TASK_DESCRIPTION>",
    "useDefaults": true
  }'
```

4. Parse the response and report the container ID to the user
5. Offer to check the container status/logs if the user wants

## Example Usage

User says: `/task-container Fix the auth bug in the login handler`

1. Check pwd: `/Users/via/Development/Dfinitiv/mojo-users` → Work instance
2. Run curl to create container with prompt "Fix the auth bug in the login handler"
3. Report: "Created container `fix-auth-abc123` on work instance"

## Additional Commands

After creating a container, offer these follow-up options:
- Check logs: `curl -s "https://<instance>/api/containers/<id>/logs" -H "X-API-Key: <key>"`
- Get result: `curl -s "https://<instance>/api/containers/<id>/result" -H "X-API-Key: <key>"`
- Kill container: `curl -s -X DELETE "https://<instance>/api/containers/<id>" -H "X-API-Key: <key>"`

$ARGUMENTS
