# saml2aws - Ubuntu Server Installation

## Tool Overview

**saml2aws** is a CLI tool that lets you authenticate against a SAML Identity Provider (IdP) and retrieve temporary AWS credentials. Instead of managing long-lived AWS access keys, you log in through your organization's SSO and saml2aws exchanges the SAML assertion for short-lived STS credentials saved to your `~/.aws/credentials` file.

- **GitHub:** <https://github.com/Versent/saml2aws>
- **Latest version at time of writing:** v2.36.19
- **Available for Ubuntu Server:** Yes. Pre-built static Linux binaries (amd64, arm64, armv6) are published with every release.

## Supported Identity Providers

saml2aws supports the following IdPs out of the box:

- ADFS (2.x / 3.x)
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
- Auth0 (MFA not supported)
- JumpCloud
- Browser-based (requires a desktop/GUI -- not suitable for headless servers)

## Prerequisites

- **curl** and **wget** (usually pre-installed on Ubuntu Server)
- **tar** (usually pre-installed)
- **AWS CLI** (optional but strongly recommended -- needed to actually use the credentials saml2aws retrieves)

No additional runtime dependencies are required. The binary is statically linked and self-contained.

## Installation Steps

These instructions install the standard binary to `/usr/local/bin`. Run them as a user with sudo access.

### 1. Fetch the latest version number

```bash
CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)
echo "Latest version: ${CURRENT_VERSION}"
```

### 2. Download and extract the tarball

For **amd64** (most common):

```bash
wget -q "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"
tar -xzf "saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"
```

For **arm64** (e.g. AWS Graviton instances):

```bash
wget -q "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_arm64.tar.gz"
tar -xzf "saml2aws_${CURRENT_VERSION}_linux_arm64.tar.gz"
```

### 3. Move the binary into your PATH

```bash
sudo mv saml2aws /usr/local/bin/
sudo chmod 755 /usr/local/bin/saml2aws
```

### 4. Clean up the downloaded archive

```bash
rm -f saml2aws_${CURRENT_VERSION}_linux_*.tar.gz
```

### 5. Verify the installation

```bash
saml2aws --version
```

You should see output like: `2.36.19`

## Headless / No-GUI Keychain Configuration

On a headless Ubuntu Server there is no graphical keyring (gnome-keyring, etc.), so saml2aws will fail when it tries to store credentials. You have two options:

### Option A: Disable the keychain entirely

Pass `--disable-keychain` to both `configure` and `login` commands. This means you will be prompted for your username and password every time you log in.

```bash
saml2aws configure --disable-keychain
saml2aws login --disable-keychain
```

### Option B: Use `pass` as the keyring backend (recommended for servers)

This stores credentials encrypted with GPG via the standard Unix password manager `pass`.

```bash
# Install pass and gnupg
sudo apt-get update && sudo apt-get install -y pass gnupg

# Generate a GPG key (follow the prompts)
gpg --gen-key

# Note the public key ID from the output (the long hex string on the "pub" line)
# Initialize pass with that key
pass init <YOUR_GPG_PUBLIC_KEY_ID>

# Tell saml2aws to use pass
echo 'export SAML2AWS_KEYRING_BACKEND=pass' >> ~/.bashrc
echo 'export GPG_TTY="$( tty )"' >> ~/.bashrc
source ~/.bashrc
```

After this, `saml2aws configure` and `saml2aws login` will store and retrieve credentials through `pass`.

## Post-Install Configuration

### Initial configuration

Run the interactive configuration to set your IdP URL, provider type, and default AWS role:

```bash
saml2aws configure
```

You will be prompted for:

- **IdP Provider:** Select your organization's IdP from the list (e.g. Okta, ADFS, OneLogin)
- **URL:** Your IdP's SSO login URL
- **Username:** Your SSO username
- **AWS Role ARN:** The role you want to assume (can be auto-detected if your IdP returns multiple roles)
- **AWS Profile:** The profile name to write credentials to (defaults to "saml")

Configuration is saved to `~/.saml2aws`.

### Logging in

```bash
saml2aws login
```

This authenticates against your IdP, retrieves a SAML assertion, exchanges it for temporary AWS STS credentials, and writes them to `~/.aws/credentials` under the configured profile (default: "saml").

### Using the credentials

```bash
# Use the saml profile directly
aws s3 ls --profile saml

# Or export into your current shell
eval $(saml2aws script)

# Or run a command with the credentials injected
saml2aws exec -- aws s3 ls
```

### Session duration

AWS defaults to 1-hour session tokens. If your AWS account and role are configured for longer sessions (up to 12 hours), you can request a longer duration:

```bash
saml2aws login --session-duration=28800
```

### Multiple accounts

You can configure named accounts for different AWS environments:

```bash
saml2aws configure -a prod
saml2aws configure -a staging
saml2aws login -a prod
saml2aws login -a staging
```

### Shell completion (optional)

```bash
# Bash
echo 'eval "$(saml2aws --completion-script-bash)"' >> ~/.bashrc

# Zsh
echo 'eval "$(saml2aws --completion-script-zsh)"' >> ~/.zshrc
```

## Notes

- **IdP configuration is your responsibility.** saml2aws handles the client side of SAML authentication. Your AWS account must have a SAML provider configured, and your IdP must be set up to return AWS role assertions. This is an AWS admin task, not something saml2aws does for you.
- **MFA handling varies by provider.** Most providers will prompt for MFA through saml2aws's interactive flow. The Browser provider requires a GUI and is not usable on headless servers.
- **Credentials are temporary.** The STS tokens expire (default 1 hour). You need to re-run `saml2aws login` when they expire.
- **U2F variant available.** If you need hardware U2F token support, download the `saml2aws-u2f` build instead of the standard one. Replace `saml2aws_` with `saml2aws-u2f_` in the download URL. Note that U2F on a headless server is unusual since it typically requires physical interaction with the token.
