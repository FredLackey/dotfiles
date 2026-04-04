# saml2aws - macOS Installation

## Tool Summary

| Field | Value |
|---|---|
| **Tool** | saml2aws |
| **Description** | CLI tool for logging in and retrieving AWS temporary credentials using a SAML Identity Provider |
| **GitHub Repo** | https://github.com/Versent/saml2aws |
| **License** | MIT |
| **Language** | Go |
| **macOS Available** | Yes (Homebrew and direct binary download) |
| **Current Version** | v2.36.19 (as of 2025-03-13) |

## What It Does

saml2aws authenticates you against a SAML-based Identity Provider (IdP), receives a SAML assertion, and exchanges it with AWS STS for temporary credentials. Those credentials get saved to your AWS credentials file under a named profile (default: "saml"). This lets you use the AWS CLI, SDKs, and console without long-lived IAM access keys.

The login flow:

1. Prompt for username/password (or read from keychain)
2. Authenticate against your SAML IdP (with MFA if configured)
3. Receive a SAML assertion containing your authorized AWS roles
4. Exchange the assertion with AWS STS for temporary credentials
5. Write credentials to `~/.aws/credentials` under your chosen profile

## Supported Identity Providers

- ADFS (2.x, 3.x)
- Azure AD
- PingFederate + PingId
- Okta
- KeyCloak (+ TOTP)
- Google Apps
- Shibboleth
- F5 APM
- Akamai
- OneLogin
- NetIQ
- Auth0 (MFA not yet supported)
- JumpCloud
- Browser-based (uses Playwright/Chromium sandbox)

## Prerequisites

- **macOS** with Homebrew installed
- **AWS CLI** installed and configured (`brew install awscli`)
- A SAML Identity Provider already configured to federate with your AWS account(s)
- Your AWS account must have a SAML provider entity and IAM roles configured for SAML federation

## Installation (Homebrew - Recommended)

```bash
# 1. Install saml2aws
brew install saml2aws

# 2. Verify the installation
saml2aws --version
```

That's it. Homebrew handles the Go build dependency automatically.

## Installation (Direct Binary Download - Alternative)

If you prefer not to use Homebrew, download the pre-built binary for your architecture:

```bash
# For Apple Silicon (M1/M2/M3/M4)
CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)
curl -LO "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_darwin_arm64.tar.gz"
tar -xzf "saml2aws_${CURRENT_VERSION}_darwin_arm64.tar.gz"
sudo mv saml2aws /usr/local/bin/
chmod +x /usr/local/bin/saml2aws

# For Intel Macs
# Replace darwin_arm64 with darwin_amd64 in the curl line above

# Verify
saml2aws --version
```

## Verification

```bash
# Check version
saml2aws --version

# Check that the binary is in your PATH
which saml2aws

# View available commands
saml2aws help
```

## Post-Install Configuration

### 1. Configure an IDP account

Run the interactive configuration wizard:

```bash
saml2aws configure
```

This prompts for:

- **IDP Provider** - Select your identity provider from the list (e.g., Okta, ADFS, AzureAD)
- **URL** - Your IdP's SSO URL
- **Username** - Your login username
- **AWS Profile** - The profile name to store credentials under (default: "saml")
- **MFA** - MFA type if applicable (e.g., Auto, TOTP, Push)

The configuration is saved to `~/.saml2aws` by default.

### 2. Test login

```bash
saml2aws login
```

If successful, temporary credentials are written to `~/.aws/credentials` under your configured profile.

### 3. Use the credentials

```bash
# Use with AWS CLI via profile
aws s3 ls --profile saml

# Or export credentials as environment variables
eval "$(saml2aws script --shell=bash)"
aws s3 ls

# Or execute a command with credentials injected
saml2aws exec -- aws s3 ls
```

### 4. Shell completion (optional)

For zsh (default on macOS), add to `~/.zshrc`:

```bash
eval "$(saml2aws --completion-script-zsh)"
```

For bash, add to `~/.bash_profile`:

```bash
eval "$(saml2aws --completion-script-bash)"
```

## Configuration for Multiple AWS Accounts

You can configure multiple named IDP accounts:

```bash
# Configure a "dev" account
saml2aws configure -a dev

# Configure a "prod" account
saml2aws configure -a prod

# Login to a specific account
saml2aws login -a dev --profile dev
saml2aws login -a prod --profile prod
```

## Useful Environment Variables

| Variable | Description |
|---|---|
| `SAML2AWS_CONFIGFILE` | Path to config file (default: `~/.saml2aws`) |
| `SAML2AWS_IDP_ACCOUNT` | Default IDP account name |
| `SAML2AWS_IDP_PROVIDER` | Override the configured IDP provider |
| `SAML2AWS_URL` | Override the IDP URL |
| `SAML2AWS_USERNAME` | Pre-fill the username |
| `SAML2AWS_MFA_TOKEN` | Pass MFA token non-interactively |
| `SAML2AWS_ROLE` | ARN of the role to assume |
| `SAML2AWS_SESSION_DURATION` | Session duration (default: 3600s, max: 43200s) |
| `SAML2AWS_REGION` | AWS region for API requests |
| `SAML2AWS_DISABLE_KEYCHAIN` | Set to disable macOS Keychain integration |

## Notes

- AWS session tokens default to 1 hour but can be extended up to 12 hours if your IAM roles and IdP are configured for it. Use the `--session-duration` flag.
- macOS Keychain is used by default to store your IdP credentials. To disable this, pass `--disable-keychain` or set `SAML2AWS_DISABLE_KEYCHAIN=true`.
- Most providers use screen scraping for authentication, which can break if the IdP updates their login pages. Keep saml2aws updated.
- The Browser provider uses Playwright (Chromium) for a more robust login flow that handles complex IdP pages and MFA challenges.
