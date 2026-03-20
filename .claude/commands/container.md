# Container Task (Short Alias)

Alias for /task-container - Start a Claude container task on the appropriate server.

## Quick Reference

**Work Instance** (~/Development/Dfinitiv/ or mojo-/savvy- projects):
- URL: `https://claudepod-work.flatmeadow.com/api`
- Key: `mojo-savvy`

**Home Instance** (personal projects):
- URL: `https://claudepod-home.flatmeadow.com/api`
- Key: `briguy`

## Steps

1. Check `pwd` to determine instance:
   - If path contains `Development/Dfinitiv` OR `mojo-` OR `savvy-` → Work
   - Otherwise → Home

2. Get the task from the user if not provided as $ARGUMENTS

3. Create container:
```bash
curl -s -X POST "<BASE_URL>/containers" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <KEY>" \
  -d '{"claudePrompt": "<TASK>", "useDefaults": true}'
```

4. Report the container ID and which instance was used

$ARGUMENTS
