# gitego How-To Guide

A practical guide for using gitego to manage multiple Git identities across GitHub, GitLab, Bitbucket, and other providers.

**Repository:** https://github.com/bgreenwell/gitego

---

## Table of Contents

**Part 1: Foundational Setup**
1. [Prerequisites](#prerequisites)
2. [GPG Signing Key Setup](#gpg-signing-key-setup)
3. [SSH Key Setup](#ssh-key-setup)
4. [Register Keys with Git Providers](#register-keys-with-git-providers)

**Part 2: gitego Installation and Configuration**
5. [Install gitego](#install-gitego)
6. [Configure gitego](#configure-gitego)
7. [Creating Profiles](#creating-profiles)
8. [Automatic Directory Switching](#automatic-directory-switching)

**Part 3: Daily Usage**
9. [Daily Workflow](#daily-workflow)
10. [Common Operations](#common-operations)
11. [Troubleshooting](#troubleshooting)

**Reference**
- [Directory Structure Example](#directory-structure-example)
- [Quick Reference](#quick-reference)

---

# Part 1: Foundational Setup

Complete these steps before installing gitego. You need your GPG signing keys and SSH keys created and registered with your Git providers first.

---

## Prerequisites

### Required Software

Verify you have these installed before proceeding:

**Git 2.13+** (required for `includeIf` support):
```bash
git --version
# Must be 2.13 or higher
```

**Homebrew** (macOS only, for installing tools):
```bash
brew --version
# If not installed: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## GPG Signing Key Setup

Some clients require signed commits to verify that commits actually came from you. GPG signing keys must be created and registered with Git providers before you can use them in gitego profiles.

### What is commit signing?

Commit signing uses GPG (GNU Privacy Guard) to cryptographically sign your commits. This proves:
- The commit was made by someone with access to the private key
- The commit hasn't been tampered with since signing

GitHub, GitLab, and Bitbucket display a "Verified" badge on signed commits.

### Step 1: Install GPG

**macOS:**
```bash
brew install gnupg pinentry-mac
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install gnupg
```

**Verify installation:**
```bash
gpg --version
```

### Step 2: Configure GPG Agent (do this now to avoid issues later)

Create the GPG agent config directory and file:

```bash
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
```

**macOS** - create `~/.gnupg/gpg-agent.conf`:
```bash
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
default-cache-ttl 3600
max-cache-ttl 86400
pinentry-program /opt/homebrew/bin/pinentry-mac
EOF
```

Note: On Intel Macs, use `/usr/local/bin/pinentry-mac` instead.

**Linux** - create `~/.gnupg/gpg-agent.conf`:
```bash
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
default-cache-ttl 3600
max-cache-ttl 86400
EOF
```

**Add to your shell profile:**

For Bash:
```bash
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
```

For Zsh:
```bash
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
```

Reload your shell:
```bash
source ~/.bashrc   # or source ~/.zshrc
```

### Step 3: Generate GPG keys for each identity

Create a separate GPG key for each client/identity that requires signed commits.

```bash
gpg --full-generate-key
```

When prompted:
1. **Key type:** Press Enter to accept `(9) ECC (sign and encrypt)` - this is the modern default and works with all Git providers
2. **Elliptic curve:** Press Enter to accept `Curve 25519` (default)
3. **Expiration:** Enter `1y` for 1 year (recommended) or `0` for no expiration, then confirm with `y`
4. **Real name:** Enter your name (e.g., `Fred Lackey`)
5. **Email:** Enter the email for this identity (must match your Git commit email)
6. **Comment:** Optional - you can enter the client name (e.g., `CCSI`)
7. **Confirm:** Press `O` for Okay
8. **Passphrase:** Enter a secure passphrase (you'll need this when signing)

Note: RSA (option 1) also works if preferred, but ECC is recommended for new keys.

**Example: Creating keys for multiple clients:**

```bash
# Key for personal use
gpg --full-generate-key
# Email: fred@personal.com

# Key for CCSI
gpg --full-generate-key
# Email: fred.lackey@consensus.com

# Key for Acme Corp
gpg --full-generate-key
# Email: flackey@acme-corp.com
```

### Step 4: Find your signing key IDs

```bash
gpg --list-secret-keys --keyid-format=long
```

Output example:
```
sec   ed25519/ABC123DEF4567890 2024-01-15 [SC] [expires: 2025-01-15]
      1234567890ABCDEF1234567890ABCDEF12345678
uid                 [ultimate] Fred Lackey (CCSI) <fred.lackey@consensus.com>
ssb   cv25519/DEF7890ABC123456 2024-01-15 [E] [expires: 2025-01-15]

sec   ed25519/XYZ789ABC1234567 2024-01-15 [SC] [expires: 2025-01-15]
      ABCDEF1234567890ABCDEF1234567890ABCDEF12
uid                 [ultimate] Fred Lackey <fred@personal.com>
ssb   cv25519/123ABC456DEF7890 2024-01-15 [E] [expires: 2025-01-15]
```

The signing key ID is the part after `ed25519/` on the `sec` line (or after `rsa4096/` if you chose RSA):
- CCSI key: `ABC123DEF4567890`
- Personal key: `XYZ789ABC1234567`

**Record your key IDs - you'll need them when creating gitego profiles.**

### Step 5: Configure Git to use GPG

```bash
# Tell Git which GPG program to use
git config --global gpg.program gpg
```

### Step 6: Test GPG signing

```bash
echo "test" | gpg --clearsign
```

If this works, you'll see signed output. If it fails, check the troubleshooting section.

---

## SSH Key Setup

Create SSH keys for each client/identity. Each key should be registered with the appropriate Git provider.

### Step 1: Generate SSH keys for each identity

```bash
# Personal
ssh-keygen -t ed25519 -C "fred@personal.com" -f ~/.ssh/id_personal

# CCSI
ssh-keygen -t ed25519 -C "fred.lackey@consensus.com" -f ~/.ssh/id_ccsi

# Acme Corp
ssh-keygen -t ed25519 -C "flackey@acme-corp.com" -f ~/.ssh/id_acme

# Add more as needed for each client
```

When prompted for a passphrase, you can either:
- Enter a passphrase (more secure, requires ssh-agent)
- Press Enter for no passphrase (less secure, more convenient)

### Step 2: Set correct permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
```

### Step 3: Add keys to ssh-agent

```bash
# Start ssh-agent if not running
eval "$(ssh-agent -s)"

# Add your keys
ssh-add ~/.ssh/id_personal
ssh-add ~/.ssh/id_ccsi
ssh-add ~/.ssh/id_acme
```

**macOS: Add to Keychain for persistence:**
```bash
ssh-add --apple-use-keychain ~/.ssh/id_personal
ssh-add --apple-use-keychain ~/.ssh/id_ccsi
ssh-add --apple-use-keychain ~/.ssh/id_acme
```

### Step 4: Verify keys are loaded

```bash
ssh-add -l
```

---

## Register Keys with Git Providers

You must register both your GPG public keys (for commit verification) and SSH public keys (for authentication) with each Git provider.

### Export your keys

**GPG public keys:**
```bash
# Export each GPG key (replace with your key IDs)
gpg --armor --export ABC123DEF4567890 > ~/gpg_ccsi.pub
gpg --armor --export XYZ789ABC1234567 > ~/gpg_personal.pub

# View a key to copy/paste
cat ~/gpg_ccsi.pub
```

**SSH public keys:**
```bash
# View each SSH public key to copy/paste
cat ~/.ssh/id_personal.pub
cat ~/.ssh/id_ccsi.pub
cat ~/.ssh/id_acme.pub
```

### Register with GitHub

1. Go to **Settings** > **SSH and GPG keys** (https://github.com/settings/keys)

2. **Add SSH key:**
   - Click "New SSH key"
   - Title: Descriptive name (e.g., "CCSI MacBook")
   - Key: Paste contents of `~/.ssh/id_ccsi.pub`
   - Click "Add SSH key"

3. **Add GPG key:**
   - Click "New GPG key"
   - Paste contents of GPG public key (the entire `-----BEGIN PGP PUBLIC KEY BLOCK-----` block)
   - Click "Add GPG key"

4. **Repeat for each GitHub account** (personal, work org, client orgs)

### Register with GitLab

1. Go to **Preferences** > **SSH Keys** (https://gitlab.com/-/profile/keys)
   - Click "Add new key"
   - Paste SSH public key
   - Set title and expiration
   - Click "Add key"

2. Go to **Preferences** > **GPG Keys** (https://gitlab.com/-/profile/gpg_keys)
   - Paste GPG public key
   - Click "Add key"

### Register with Bitbucket

1. Go to **Personal settings** > **SSH keys** (https://bitbucket.org/account/settings/ssh-keys/)
   - Click "Add key"
   - Paste SSH public key
   - Click "Add key"

2. Go to **Personal settings** > **GPG keys**
   - Click "Add key"
   - Paste GPG public key
   - Click "Add key"

### Test SSH connections

When testing SSH connections, you must specify which key to use with the `-i` flag. This is especially important when you have multiple accounts on the same provider (e.g., multiple GitHub accounts).

**Test each key individually:**

```bash
# Test personal key against GitHub
ssh -i ~/.ssh/id_personal -T git@github.com
# Expected: Hi FredLackey! You've successfully authenticated...

# Test CCSI key against GitHub
ssh -i ~/.ssh/id_ccsi -T git@github.com
# Expected: Hi FredLackeyCCSI! You've successfully authenticated...

# Test Acme key against GitLab
ssh -i ~/.ssh/id_acme -T git@gitlab.com
# Expected: Welcome to GitLab, @flackey-acme!

# Test against Bitbucket
ssh -i ~/.ssh/id_acme -T git@bitbucket.org
# Expected: logged in as flackey-acme
```

**Important:** The username in the response should match the account where you registered that specific SSH key. If you see the wrong username, the key is registered to a different account than expected.

**Note:** Messages like "GitHub does not provide shell access" or "You've successfully authenticated, but..." are **normal and expected**. Git providers don't allow interactive shell sessions - SSH is only used for Git operations. The important part is seeing your correct username in the response.

**Troubleshooting wrong identity:**
```bash
# See which key SSH would use by default (without -i flag)
ssh -v git@github.com 2>&1 | grep "Offering public key"

# If the wrong key is offered first, always use -i to specify the correct one
```

---

# Part 2: gitego Installation and Configuration

Now that your keys are created and registered, install and configure gitego.

---

## Install gitego

### Step 1: Install Go

**macOS:**
```bash
brew install go
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install golang-go
```

**Verify:**
```bash
go version
# Output: go version go1.24.x ...
```

### Step 2: Install gitego

```bash
go install github.com/bgreenwell/gitego@main
```

**Note:** Use `@main` instead of `@latest` to get the most recent features including GPG signing key support. The `@latest` tag installs the most recent release, which may not include newer features that have been merged to main but not yet released.

### Step 3: Add Go bin to PATH

Add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/go/bin:$PATH"
```

Reload:
```bash
source ~/.bashrc   # or source ~/.zshrc
```

### Step 4: Verify installation

```bash
gitego --version
```

---

## Configure gitego

### Set up credential helper

This allows gitego to provide credentials (PATs) for HTTPS operations:

```bash
# Clear any existing credential helpers
git config --global credential.helper ""

# Add gitego as the credential helper (use single quotes!)
git config --global --add credential.helper '!gitego credential'
```

### Verify configuration

```bash
git config --global --get-all credential.helper
# Output: !gitego credential
```

---

## Creating Profiles

Now create gitego profiles using the keys you generated earlier.

### Profile structure

A profile contains:
- **name** - Your name for commits
- **email** - Email for commits (must match GPG key email)
- **username** - Username for authentication
- **ssh-key** - Path to SSH private key
- **signing-key** - GPG key ID for commit signing
- **pat** - Personal Access Token (for HTTPS, optional)

### Gather your key information

Before creating profiles, list your keys so you have all the IDs in one place:

```bash
# List GPG signing key IDs
gpg --list-secret-keys --keyid-format=long

# List SSH key files
ls -la ~/.ssh/id_*
```

Record the GPG key ID (the part after `ed25519/` or `rsa4096/`) and SSH key path for each identity you'll be configuring.

**Verify your username on each provider:**

Test each SSH key against each provider to confirm the exact username registered. The provider will echo back the username associated with that key:

```bash
# Test your keys against GitHub
ssh -i ~/.ssh/id_personal -T git@github.com
# Response: Hi FredLackey! You've successfully authenticated...

ssh -i ~/.ssh/id_ccsi -T git@github.com
# Response: Hi FredLackeyCCSI! You've successfully authenticated...

# Test against GitLab (hosted)
ssh -i ~/.ssh/id_acme -T git@gitlab.com
# Response: Welcome to GitLab, @flackey-acme!

# Test against Bitbucket
ssh -i ~/.ssh/id_personal -T git@bitbucket.org
# Response: authenticated via ssh key.
# NOTE: Bitbucket does NOT echo your username. Check your username at:
# https://bitbucket.org/account/settings/ (look for "Username" field)

# Test against self-hosted Gitea server
ssh -i ~/.ssh/id_personal -T git@git.fredlackey.com
# Response: Hi there, FredLackey! You've successfully authenticated...

# Test against self-hosted GitLab server
ssh -i ~/.ssh/id_briskhaven -T git@git.briskhaven.com
# Response: Welcome to GitLab, @flackey!

# Test against server using custom SSH port (e.g., port 30029)
ssh -i ~/.ssh/id_briskhaven -p 30029 -T git@git.briskhaven.net
# Response: Hi there, flackey! You've successfully authenticated...
```

**Note:** Self-hosted servers use the same pattern - just replace the hostname with your server's domain. The response format varies by platform (Gitea vs GitLab vs others), but all will display the authenticated username.

**Custom SSH ports:** If your server uses a non-standard SSH port, add `-p PORT` to the command. For easier daily use, configure the port in `~/.ssh/config`:

```
Host git.briskhaven.net
    HostName git.briskhaven.net
    Port 30029
    User git
    IdentityFile ~/.ssh/id_briskhaven
```

This allows git commands to work without specifying the port each time.

The username in each response is the exact value you need for the `--username` flag when creating that profile. Record these - they may differ across providers even for the same identity.

### Create profiles for each provider and identity

**Important:** Your username may differ across providers. For example, your personal GitHub username might be "FredLackey" while your personal Bitbucket username is "fred-lackey". Create separate profiles for each provider where usernames differ.

The SSH key and GPG signing key can be shared across providers for the same identity (they identify *you*), but the username must match what's registered on each specific provider.

**Example: Single client using one provider**

If a client only uses one provider, a simple profile name works:

```bash
# CCSI only uses GitHub
gitego add ccsi \
    --name "Fred Lackey" \
    --email "fred.lackey@consensus.com" \
    --username "FredLackeyCCSI" \
    --ssh-key ~/.ssh/id_ccsi \
    --signing-key ABC123DEF4567890
```

**Example: Personal accounts across multiple providers**

When you have accounts on multiple providers with different usernames, create provider-specific profiles:

```bash
# Personal GitHub account
gitego add personal-github \
    --name "Fred Lackey" \
    --email "fred@personal.com" \
    --username "FredLackey" \
    --ssh-key ~/.ssh/id_personal \
    --signing-key XYZ789ABC1234567

# Personal Bitbucket account (different username)
gitego add personal-bitbucket \
    --name "Fred Lackey" \
    --email "fred@personal.com" \
    --username "fred-lackey" \
    --ssh-key ~/.ssh/id_personal \
    --signing-key XYZ789ABC1234567

# Personal Gitea account (different username again)
gitego add personal-gitea \
    --name "Fred Lackey" \
    --email "fred@personal.com" \
    --username "flackey" \
    --ssh-key ~/.ssh/id_personal \
    --signing-key XYZ789ABC1234567
```

Notice the SSH key and signing key are the same across all personal profiles - only the username changes per provider.

**Example: Client using multiple providers**

```bash
# Acme uses both GitLab and Bitbucket
gitego add acme-gitlab \
    --name "Fred Lackey" \
    --email "flackey@acme-corp.com" \
    --username "flackey-acme" \
    --ssh-key ~/.ssh/id_acme

gitego add acme-bitbucket \
    --name "Fred Lackey" \
    --email "flackey@acme-corp.com" \
    --username "acme-flackey" \
    --ssh-key ~/.ssh/id_acme
```

### View profiles

```bash
gitego list
```

Output:
```
ACTIVE  PROFILE            NAME          EMAIL                          ATTRIBUTES
------  -------            ----          -----                          ----------
        acme-bitbucket     Fred Lackey   flackey@acme-corp.com          [SSH]
        acme-gitlab        Fred Lackey   flackey@acme-corp.com          [SSH]
        ccsi               Fred Lackey   fred.lackey@consensus.com      [SSH GPG]
        personal-bitbucket Fred Lackey   fred@personal.com              [SSH GPG]
        personal-gitea     Fred Lackey   fred@personal.com              [SSH GPG]
        personal-github    Fred Lackey   fred@personal.com              [SSH GPG]
```

### Set default profile

```bash
gitego use personal-github
```

---

## Automatic Directory Switching

Configure gitego to automatically switch profiles based on your working directory.

### Directory organization strategies

With provider-specific profiles, you have two options for organizing directories:

**Option A: Organize by client/identity, separate by provider within**

Best when you work primarily by client but use multiple providers per client.

```
~/projects/
    personal/
        github/       # -> personal-github profile
        bitbucket/    # -> personal-bitbucket profile
    ccsi/             # -> ccsi profile (single provider)
    acme/
        gitlab/       # -> acme-gitlab profile
        bitbucket/    # -> acme-bitbucket profile
```

**Option B: Organize by provider, separate by client within**

Best when you work primarily on one provider at a time.

```
~/projects/
    github/
        personal/     # -> personal-github profile
        ccsi/         # -> ccsi profile
    gitlab/
        acme/         # -> acme-gitlab profile
    bitbucket/
        personal/     # -> personal-bitbucket profile
        acme/         # -> acme-bitbucket profile
```

### Set up auto-switching rules

**Example using Option A (by client):**

```bash
# Personal projects by provider
gitego auto ~/projects/personal/github/ personal-github
gitego auto ~/projects/personal/bitbucket/ personal-bitbucket
gitego auto ~/projects/personal/gitea/ personal-gitea

# CCSI (single provider, simpler path)
gitego auto ~/projects/ccsi/ ccsi

# Acme by provider
gitego auto ~/projects/acme/gitlab/ acme-gitlab
gitego auto ~/projects/acme/bitbucket/ acme-bitbucket
```

### Create the directory structure

```bash
# Personal directories by provider
mkdir -p ~/projects/personal/github
mkdir -p ~/projects/personal/bitbucket
mkdir -p ~/projects/personal/gitea

# Client directories
mkdir -p ~/projects/ccsi
mkdir -p ~/projects/acme/gitlab
mkdir -p ~/projects/acme/bitbucket
```

### Test auto-switching

```bash
cd ~/projects/ccsi
gitego status
# Output: Active profile: ccsi (auto: ~/projects/ccsi/)

cd ~/projects/personal/github
gitego status
# Output: Active profile: personal-github (auto: ~/projects/personal/github/)

cd ~/projects/acme/gitlab
gitego status
# Output: Active profile: acme-gitlab (auto: ~/projects/acme/gitlab/)
```

**Important:** When testing from a directory that isn't inside a Git repository, `gitego status` will show the correct profile name but the Name and Email fields may appear empty:

```
--- Git Identity Status ---
  Name:
  Email:
  Source: gitego auto-rule for profile 'ccsi'
---------------------------
```

This is expected. Git's `includeIf gitdir:` directive only applies when you're inside an actual Git repository. To see the full identity, test from within a repo:

```bash
cd ~/projects/ccsi/some-repo    # enter an actual git repository
gitego status
# Now shows Name, Email, and profile correctly
```

The identity only matters when you're inside a repo where you'd be making commits, so this behavior is correct.

---

# Part 3: Daily Usage

---

## Daily Workflow

### Cloning a repository

Navigate to the correct parent directory, then clone:

```bash
cd ~/projects/ccsi
git clone git@github.com:consensus/backend-api.git
# Uses ccsi profile automatically
```

### Making commits

Commits automatically use the correct identity:

```bash
cd ~/projects/ccsi/backend-api
git add .
git commit -m "Add new feature"
# Signed with CCSI GPG key, authored by fred.lackey@consensus.com

# Verify
git log -1 --format="Author: %an <%ae>"
```

### Pushing changes

```bash
git push origin main
# Uses CCSI SSH key automatically
```

---

## Common Operations

| Task | Command |
|------|---------|
| Check active profile | `gitego status` |
| List all profiles | `gitego list` |
| Switch profile manually | `gitego use profile-name` |
| Edit profile | `gitego edit name --email "new@email.com"` |
| Add signing key to profile | `gitego edit name --signing-key KEY_ID` |
| Remove profile | `gitego rm name` |
| Install pre-commit hook | `gitego install-hook` |

---

## Troubleshooting

### "command not found: gitego"

Go bin directory not in PATH:
```bash
export PATH="$HOME/go/bin:$PATH"
source ~/.bashrc
```

### "event not found" when configuring credential helper

Use single quotes:
```bash
# Wrong
git config --global --add credential.helper "!gitego credential"

# Correct
git config --global --add credential.helper '!gitego credential'
```

### "gpg failed to sign the data"

```bash
# Test GPG
echo "test" | gpg --clearsign

# Restart agent
gpgconf --kill gpg-agent

# Ensure TTY is set
export GPG_TTY=$(tty)
```

### SSH key not being used

```bash
# Check profile has SSH key
gitego list

# Check Git's SSH command
git config core.sshCommand

# Test SSH directly
ssh -i ~/.ssh/id_ccsi -T git@github.com
```

### Wrong identity for commits

```bash
# Check active profile
gitego status

# Verify Git config
git config user.email

# Ensure auto rule exists
gitego auto ~/path/to/projects/ correct-profile
```

---

## Directory Structure Example

```
~/projects/
├── personal/
│   ├── github/                  # gitego auto ~/projects/personal/github/ personal-github
│   │   ├── my-website/
│   │   └── side-project/
│   ├── bitbucket/               # gitego auto ~/projects/personal/bitbucket/ personal-bitbucket
│   │   └── legacy-app/
│   └── gitea/                   # gitego auto ~/projects/personal/gitea/ personal-gitea
│       └── homelab-scripts/
├── ccsi/                        # gitego auto ~/projects/ccsi/ ccsi
│   ├── backend-api/
│   └── frontend-app/
└── acme/
    ├── gitlab/                  # gitego auto ~/projects/acme/gitlab/ acme-gitlab
    │   ├── main-service/
    │   └── utils/
    └── bitbucket/               # gitego auto ~/projects/acme/bitbucket/ acme-bitbucket
        └── deploy-scripts/
```

---

## Quick Reference

### Key IDs to record

**Identity keys** (shared across providers for same identity):

| Identity | GPG Key ID | SSH Key Path | Email |
|----------|------------|--------------|-------|
| Personal | (your key) | ~/.ssh/id_personal | fred@personal.com |
| CCSI | (your key) | ~/.ssh/id_ccsi | fred.lackey@consensus.com |
| Acme | (your key) | ~/.ssh/id_acme | flackey@acme-corp.com |

**Provider usernames** (may differ per provider):

| Identity | GitHub | GitLab | Bitbucket | Gitea |
|----------|--------|--------|-----------|-------|
| Personal | FredLackey | - | fred-lackey | flackey |
| CCSI | FredLackeyCCSI | - | - | - |
| Acme | - | flackey-acme | acme-flackey | - |

### Commands

```bash
# GPG
gpg --list-secret-keys --keyid-format=long    # List keys
gpg --armor --export KEY_ID                    # Export public key

# SSH
ssh-add -l                                     # List loaded keys
ssh -i ~/.ssh/id_personal -T git@github.com   # Test specific key

# gitego
gitego add name --name "N" --email "E" --ssh-key ~/.ssh/key --signing-key KEY
gitego list                                    # Show profiles
gitego use name                                # Set default
gitego auto ~/path/ name                       # Auto-switch rule
gitego status                                  # Current profile
```

---

## Summary

Setup order:
1. **Install GPG** and generate keys for each identity
2. **Generate SSH keys** for each identity
3. **Register keys** with Git providers (GitHub, GitLab, Bitbucket, Gitea)
4. **Install gitego**
5. **Create profiles** - one per provider if usernames differ (e.g., `personal-github`, `personal-bitbucket`)
6. **Set up auto-switching** by directory to match your profile structure

Once configured, just `cd` into a project and use standard `git` commands. gitego handles identity switching automatically.
