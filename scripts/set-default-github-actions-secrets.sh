#!/bin/bash
# Sets default GitHub Actions secrets for Cloudflare deployments
# Reads from ~/.secret_env_vars

set -e

SECRETS_FILE="$HOME/.secret_env_vars"

# Check if we're in a git repo with a GitHub remote
if ! git remote get-url origin 2>/dev/null | grep -q "github.com"; then
    echo "Error: Not in a git repo with a GitHub remote"
    exit 1
fi

# Load secrets from file if it exists
if [ -f "$SECRETS_FILE" ]; then
    source "$SECRETS_FILE"
else
    echo "Error: $SECRETS_FILE not found"
    exit 1
fi

# Check for required values
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Error: CLOUDFLARE_API_TOKEN not set in $SECRETS_FILE"
    exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "Error: CLOUDFLARE_ACCOUNT_ID not set in $SECRETS_FILE"
    exit 1
fi

# Get repo name for confirmation
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)

echo "Setting Cloudflare secrets for: $REPO"

gh secret set CLOUDFLARE_API_TOKEN --body "$CLOUDFLARE_API_TOKEN"
echo "✓ CLOUDFLARE_API_TOKEN set"

gh secret set CLOUDFLARE_ACCOUNT_ID --body "$CLOUDFLARE_ACCOUNT_ID"
echo "✓ CLOUDFLARE_ACCOUNT_ID set"

echo ""
echo "Done! GitHub Actions secrets configured for $REPO"
