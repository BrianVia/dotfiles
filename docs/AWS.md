# AWS Configuration Setup

This dotfiles repo includes your AWS SSO configuration. Here's how to use it:

## File Structure

```
.aws/
├── config           # Profile and SSO configuration (version controlled)
├── credentials      # API keys (IGNORED - keep secret!)
└── cli/
    └── config       # AWS CLI configuration
```

## Usage

### Option 1: AWS SSO (Recommended)

Your profiles are configured for SSO. To authenticate:

```bash
# Login to a specific profile
aws sso login --profile dfinitiv-brian
aws sso login --profile dfinitiv-mojo-dev-power-user
aws sso login --profile dfinitiv-mojo-test-power-user
aws sso login --profile dfinitiv-mojo-prod-power-user

# Use AWS CLI with SSO
aws s3 ls --profile dfinitiv-mojo-dev-power-user

# Set default profile
export AWS_PROFILE=dfinitiv-mojo-dev-power-user
```

### Option 2: Using 1Password (for API Keys)

If you need to use API keys instead of SSO:

1. Store your AWS credentials in 1Password
2. Set up environment variables:

```bash
# Add to ~/.secret_env_vars
export AWS_ACCESS_KEY_ID=$(op read "op://Private/AWS/access_key")
export AWS_SECRET_ACCESS_KEY=$(op read "op://Private/AWS/secret_key")
```

3. Load secrets:
```bash
eval $(op signin)
```

### Option 3: AWS Vault (Encrypted Local Storage)

```bash
# Install aws-vault
brew install aws-vault

# Add credentials
aws-vault add dfinitiv-brian

# Use credentials
aws-vault exec dfinitiv-brian -- aws s3 ls
```

## Profile Switcher

Your `.zshrc` includes an `sso()` function for quick profile switching:

```bash
sso  # Lists available profiles and switches to one
```

## Environment Variables

After setup, these are available in your shell:

```bash
export DEV_USER_ID='ef4a1216-72d4-4456-9c12-0c801a6a78bf'
export TEST_USER_ID='e89d330c-8ec0-4151-a76a-30e8bdbef44b'
```

## Troubleshooting

### SSO Session Expired
```bash
aws sso login --profile dfinitiv-brian
```

### Clear SSO Cache
```bash
rm -rf ~/.aws/sso/cache/*
```

### Check Current Identity
```bash
aws sts get-caller-identity --profile dfinitiv-brian
```

## Security Notes

⚠️ **NEVER commit:**
- `.aws/credentials` - Contains API keys
- `.aws/sso/` - Contains SSO tokens
- `.secret_env_vars` - Contains sensitive env vars

These are in `.gitignore` by default.

✅ **SAFE to commit:**
- `.aws/config` - Contains only profile names and settings
- Account IDs and role names

## References

- [AWS SSO Docs](https://docs.aws.amazon.com/singlesignon/)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [aws-vault GitHub](https://github.com/99designs/aws-vault)
