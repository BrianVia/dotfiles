# GitHub README Fetcher

A simple script to fetch README files from internal GitHub packages and save them as individual markdown files.

## Setup

1. Ensure you have Bun installed
2. Set your GitHub token: `export GITHUB_TOKEN=your_token_here`
3. Configure your packages in `packages.json`

## Usage

```bash
# Fetch all READMEs from packages.json
bun fetch-readme.ts

# Use custom config file
bun fetch-readme.ts my-packages.json

# Custom output directory
bun fetch-readme.ts --output ./docs

# Quiet mode (for cron jobs)
bun fetch-readme.ts --quiet
```

## Cron Job Setup (macOS)

To run twice daily (8 AM and 8 PM):

```bash
# Edit your crontab
crontab -e

# Add this line:
0 8,20 * * * cd /Users/via/scripts && /opt/homebrew/bin/bun fetch-readme.ts --quiet >> /Users/via/scripts/readme-fetcher.log 2>&1
```

**Important for macOS:**
1. Give Terminal/cron full disk access in System Settings > Privacy & Security > Full Disk Access
2. Or use launchd instead of cron (recommended):

Create `~/Library/LaunchAgents/com.readme.fetcher.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.readme.fetcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/bun</string>
        <string>/Users/via/scripts/fetch-readme.ts</string>
        <string>--quiet</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/via/scripts</string>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Hour</key>
            <integer>8</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Hour</key>
            <integer>20</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>/Users/via/scripts/readme-fetcher.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/via/scripts/readme-fetcher.log</string>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.readme.fetcher.plist
```

### Cron Job Features

- **Exit codes**: Script exits with code 1 on errors, 0 on success
- **Quiet mode**: Use `--quiet` to minimize output 
- **Error handling**: Failed fetches are logged and cause non-zero exit
- **Rate limiting**: 1 second delay between API calls

## Configuration

`packages.json` format:
```json
[
  {
    "url": "https://github.com/owner/repo/pkgs/npm/package",
    "name": "custom-name"
  }
]
```

## Projects

### savvy-guides
- **Repository**: [dfinitiv/savvy-guides](https://github.com/dfinitiv/savvy-guides)
- **Language**: TypeScript
- **Created**: September 12, 2024
- **Stars**: 0 | **Forks**: 3

## Output

Creates individual markdown files with frontmatter:
- `package-name.md`
- Includes source URL and fetch timestamp
- Handles errors gracefully

## Environment Variables

- `GITHUB_TOKEN` - Required GitHub personal access token