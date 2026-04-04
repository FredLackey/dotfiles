# saml2aws - Installation on Ubuntu WSL

## Tool Description

saml2aws is a CLI tool that enables you to log in and retrieve AWS temporary credentials using a SAML Identity Provider (IdP). It authenticates against your organization's IdP (such as Okta, ADFS, Azure AD, PingFederate, OneLogin, KeyCloak, Google Apps, etc.), builds a SAML assertion, and exchanges it with AWS STS for temporary credentials that get saved to your `~/.aws/credentials` file.

Written in Go. Single static binary with no runtime dependencies.

## Official Documentation

- GitHub: <https://github.com/Versent/saml2aws>
- License: MIT
- Latest version at time of writing: v2.36.19 (March 2025)

## Ubuntu WSL Availability

**Yes.** saml2aws provides prebuilt Linux amd64 and arm64 binaries that work in WSL without modification. The official README includes a dedicated WSL configuration section.

## Prerequisites / Dependencies

- `curl` or `wget` (for downloading the binary)
- `tar` (for extracting the archive)
- AWS CLI installed and configured (for using the credentials saml2aws retrieves)
- A SAML Identity Provider already configured with AWS (your organization sets this up)
- For credential storage in WSL: either `pass` + `gnupg` or use the `--disable-keychain` flag (see WSL-Specific Notes below)

## Installation Steps

### 1. Download and install the binary

```bash
# Fetch the latest version number
CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)

# Download the Linux amd64 tarball
wget -q "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"

# Extract it
tar -xzf "saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"

# Move the binary into your PATH (requires sudo)
sudo mv saml2aws /usr/local/bin/
sudo chmod +x /usr/local/bin/saml2aws

# Clean up the tarball
rm -f "saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"
```

If you prefer a user-local install without sudo:

```bash
mkdir -p ~/.local/bin

CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)

wget -q "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz" -O - | tar -xz -C ~/.local/bin

chmod u+x ~/.local/bin/saml2aws
```

If using `~/.local/bin`, make sure it is in your PATH. Add this to `~/.bashrc` or `~/.zshrc` if it is not already there:

```bash
export PATH="$PATH:$HOME/.local/bin"
```

### 2. Verify the installation

```bash
saml2aws --version
```

You should see output like `2.36.19` (or whatever the current version is).

### 3. Enable shell autocompletion (optional)

For bash, add to `~/.bashrc`:

```bash
eval "$(saml2aws --completion-script-bash)"
```

For zsh, add to `~/.zshrc`:

```bash
eval "$(saml2aws --completion-script-zsh)"
```

## Post-Install Configuration

### Configure your IdP account

```bash
saml2aws configure
```

This will interactively prompt you for:

- **IdP Provider** - Select your organization's provider (Okta, ADFS, AzureAD, Ping, OneLogin, etc.)
- **URL** - Your IdP login URL
- **Username** - Your IdP username/email
- **AWS Role ARN** - The IAM role to assume (optional, can be selected at login time)
- **AWS Profile** - The profile name to save credentials under (defaults to "saml")

Configuration is saved to `~/.saml2aws`.

### Log in and retrieve credentials

```bash
saml2aws login
```

This authenticates against your IdP, handles MFA if configured, and writes temporary AWS credentials to `~/.aws/credentials` under the configured profile name.

### Use the credentials

```bash
# Use the saml profile directly
aws sts get-caller-identity --profile saml

# Or export into your current shell session
eval "$(saml2aws script)"

# Or run a command with the credentials injected
saml2aws exec -- aws s3 ls
```

## WSL-Specific Notes

### Keychain / credential storage issue

WSL does not have a graphical desktop environment by default. saml2aws uses `gnome-keyring` as its default credential backend, which requires D-Bus and X11. Without those, you will see this error when running `configure` or `login`:

```
No such interface "org.freedesktop.DBus.Properties" on object at path /
```

There are two ways to handle this:

#### Option A: Disable the keychain entirely

Add `--disable-keychain` to both `configure` and `login` commands:

```bash
saml2aws configure --disable-keychain
saml2aws login --disable-keychain
```

The downside is that you will need to enter your username and password every time you run `login`. This is the simpler option if you do not mind typing credentials each time.

#### Option B: Use `pass` as the credential backend

This stores your credentials encrypted on disk using GPG. It takes a few minutes to set up but then credentials are cached between sessions.

1. Install `pass` and `gnupg`:

   ```bash
   sudo apt-get update && sudo apt-get install -y pass gnupg
   ```

2. Generate a GPG key:

   ```bash
   gpg --gen-key
   ```

   Follow the prompts. Note the public key ID from the output (the long hex string on the `pub` line).

3. Initialize the pass store with your GPG key:

   ```bash
   pass init <YOUR_GPG_PUBLIC_KEY_ID>
   ```

4. Set environment variables. Add these to your `~/.bashrc` or `~/.zshrc`:

   ```bash
   export SAML2AWS_KEYRING_BACKEND=pass
   export GPG_TTY="$(tty)"
   ```

5. Source your profile or open a new terminal, then run `saml2aws configure` and `saml2aws login` as normal. You will be prompted once for your GPG passphrase, and credentials will be stored encrypted.

### Session duration

AWS defaults to 1-hour session tokens. If your organization has configured longer durations (up to 12 hours), you can request them with:

```bash
saml2aws login --session-duration=28800
```

Or set it in your `~/.saml2aws` config file under `aws_session_duration`.

### Multiple AWS accounts

If you need to authenticate to multiple AWS accounts, use named profiles:

```bash
saml2aws configure -a dev-account -p dev
saml2aws configure -a prod-account -p prod

saml2aws login -a dev-account
saml2aws login -a prod-account
```

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
- Auth0 (MFA not currently supported)
- JumpCloud
- Browser-based (uses Playwright/Chromium -- may not work in headless WSL)

## Notes

- saml2aws is a single Go binary with no runtime dependencies beyond what ships with Ubuntu.
- The `Browser` provider uses a Chromium window via Playwright and is unlikely to work in WSL unless you have WSLg (Windows 11) or X11 forwarding configured. Stick with the native IdP providers when running in WSL.
- Temporary credentials expire. You will need to re-run `saml2aws login` periodically (default every hour, or whatever your session duration is set to).
- For U2F/FIDO support, download the `saml2aws-u2f` variant instead of the standard binary. Replace `saml2aws_` with `saml2aws-u2f_` in the download URL.
