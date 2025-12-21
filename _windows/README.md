# Windows Development Environment Setup

Automated PowerShell script for setting up a Windows development machine with essential tools and Git identity management. This is a standalone approach separate from the main dotfiles repository (which focuses on macOS and Linux).

## What It Does

The script performs two phases:

### Phase 1: Install Development Tools

- **Package Manager**: Chocolatey
- **Version Control**: Git for Windows (includes Git Bash)
- **Node.js**: nvm-windows, Node 22, Yarn
- **Go**: golang + gitego
- **Editors**: NeoVim, Visual Studio Code
- **Utilities**: jq, yq
- **Build Tools**: Visual Studio Build Tools
- **Security**: Gpg4win (GPG + pinentry)
- **Other**: Windows Terminal, Google Chrome, Tailscale

### Phase 2: Configure Git Identities (Automated)

For each identity defined in the configuration:

- **SSH keys**: Generated automatically (ED25519, no passphrase)
- **GPG keys**: Generated automatically (ED25519, no passphrase, 1-year expiry)
- **SSH config**: Generated at `~/.ssh/config`
- **SSH agent**: Windows service enabled and keys added
- **Git config**: GPG program, credential helper (gitego), commit signing enabled
- **Project directories**: Created at configured root (e.g., `C:\_\FredLackey`)
- **gitego profiles**: Created with SSH key and GPG signing key
- **Auto-switch rules**: Directory-based profile switching

## Requirements

- Windows 10 (build 19041+) or Windows 11
- PowerShell running as Administrator
- Internet connection

## Usage

```powershell
irm https://raw.github.com/fredlackey/dotfiles/main/_windows/setup.ps1 | iex
```

## Post-Installation

After the script completes:

1. **Restart PowerShell** (or your terminal)

2. **Activate Node.js**:
   ```powershell
   nvm use 22
   ```

3. **Register public keys** with Git providers (displayed at end of script):
   - GitHub: https://github.com/settings/keys
   - GitLab: https://gitlab.com/-/profile/keys
   - Bitbucket: https://bitbucket.org/account/settings/ssh-keys/

4. **Test SSH connections**:
   ```powershell
   ssh -T git@github.com
   ```

5. **Verify gitego**:
   ```powershell
   gitego list
   gitego status
   ```

6. **Log in to Tailscale** (if needed):
   ```powershell
   tailscale up
   ```

### Adding a New Project Folder (Existing Identity)

For projects that use an existing identity (e.g., contributing to a client's GitHub repo with your personal account):

1. Copy the commands below into PowerShell
2. Modify `$PROJECT_DIR` and `$PROFILE_NAME` for your project
3. Press Enter to run

```powershell
$PROJECT_DIR  = "BobSmith"      # Folder name under C:\_
$PROFILE_NAME = "personal"      # Existing gitego profile to use

New-Item -ItemType Directory -Force -Path "C:\_\$PROJECT_DIR"
gitego auto "C:\_\$PROJECT_DIR\" $PROFILE_NAME
```

Verify: `cd C:\_\BobSmith && gitego status`

---

### Adding a New Client/Company (New Identity)

For clients requiring separate SSH/GPG keys and a dedicated identity:

1. Copy the variables block below into PowerShell
2. Modify the values for your client
3. Press Enter to set the variables
4. Copy/paste each subsequent step directly into PowerShell (no modifications needed)

**Step 1: Set variables** (modify these values, then paste into PowerShell)

```powershell
$CLIENT_NAME    = "abcinc"
$CLIENT_DIR     = "ABCInc"
$CLIENT_EMAIL   = "you@abcinc.com"
$CLIENT_USER    = "YourABCUsername"
$CLIENT_HOST    = "github-abcinc"      # SSH host alias
$CLIENT_HOSTNAME = "github.com"        # Actual hostname
$FULL_NAME      = "Your Name"
```

**Step 2: Generate SSH key** (copy/paste as-is)

```powershell
ssh-keygen -t ed25519 -C $CLIENT_EMAIL -f "$env:USERPROFILE\.ssh\id_$CLIENT_NAME" -N '""' -q
ssh-add "$env:USERPROFILE\.ssh\id_$CLIENT_NAME"
```

**Step 3: Update SSH config** (copy/paste as-is)

```powershell
@"

# $CLIENT_DIR
Host $CLIENT_HOST
    HostName $CLIENT_HOSTNAME
    Port 22
    User git
    IdentityFile ~/.ssh/id_$CLIENT_NAME
    IdentitiesOnly yes
"@ | Add-Content "$env:USERPROFILE\.ssh\config"
```

**Step 4: Generate GPG key** (copy/paste as-is)

```powershell
gpg --batch --passphrase "" --quick-generate-key "$FULL_NAME <$CLIENT_EMAIL>" ed25519 sign 1y
$GPG_KEY_ID = (gpg --list-secret-keys --keyid-format=long $CLIENT_EMAIL | Select-String "(ed25519|rsa\d+)/([A-F0-9]+)").Matches.Groups[2].Value
Write-Host "GPG Key ID: $GPG_KEY_ID"
```

**Step 5: Create project directory** (copy/paste as-is)

```powershell
New-Item -ItemType Directory -Force -Path "C:\_\$CLIENT_DIR"
```

**Step 6: Create gitego profile and auto-switch** (copy/paste as-is)

```powershell
gitego add $CLIENT_NAME `
    --name $FULL_NAME `
    --email $CLIENT_EMAIL `
    --username $CLIENT_USER `
    --ssh-key "$env:USERPROFILE\.ssh\id_$CLIENT_NAME" `
    --signing-key $GPG_KEY_ID

gitego auto "C:\_\$CLIENT_DIR\" $CLIENT_NAME
```

**Step 7: Display public keys for registration** (copy/paste as-is)

```powershell
Write-Host "`n--- SSH Public Key ---"
Get-Content "$env:USERPROFILE\.ssh\id_$CLIENT_NAME.pub"
Write-Host "`n--- GPG Public Key ---"
gpg --armor --export $GPG_KEY_ID
```

**Step 8: Register and test**

1. Add SSH public key to client's Git provider
2. Add GPG public key to client's Git provider
3. Test SSH: `ssh -T git@$CLIENT_HOST`
4. Verify gitego: `cd C:\_\$CLIENT_DIR && gitego status`

## Directory Structure

After setup:

```
C:\_                                    # ProjectsRoot
├── YourName\                           # Personal projects (auto-switches to "personal")
├── CompanyA\                           # Work projects (auto-switches to "work")
└── ...

%USERPROFILE%\.ssh\
├── config                              # Generated SSH config
├── id_personal                         # SSH private key
├── id_personal.pub                     # SSH public key (register with providers)
├── id_work
└── id_work.pub
```

## What Gets Configured

### Git Global Config

```
gpg.program = C:\Program Files (x86)\GnuPG\bin\gpg.exe
credential.helper = !gitego credential
commit.gpgsign = true
user.useConfigOnly = true
init.defaultBranch = main
```

### SSH Config (Generated)

```
Host github.com
    HostName github.com
    Port 22
    User git
    IdentityFile ~/.ssh/id_personal
    IdentitiesOnly yes
```

### gitego

- Profiles created with name, email, username, SSH key, GPG signing key
- Auto-switch rules map project directories to profiles
- Credential helper configured for Git authentication

## Idempotent

The script can be run multiple times safely:

- Existing SSH keys are skipped
- Existing GPG keys are skipped
- Existing Chocolatey packages are skipped
- Existing gitego profiles are skipped
- SSH config is regenerated (overwritten)

## What Is NOT Installed

| Category | Reason |
|----------|--------|
| Docker | Requires WSL2/Hyper-V (nested virtualization) |
| Bash configuration | Git Bash provides Bash, but shell customization is out of scope |
| tmux | Requires WSL; not native to Windows |
| Shell aliases/functions | Would require porting to PowerShell |

## Chocolatey Packages

| Tool | Package |
|------|---------|
| Git for Windows | `git` |
| nvm-windows | `nvm` |
| Go | `golang` |
| NeoVim | `neovim` |
| VSCode | `vscode` |
| jq | `jq` |
| yq | `yq` |
| VS Build Tools | `visualstudio2022buildtools` |
| Google Chrome | `googlechrome` |
| Windows Terminal | `microsoft-windows-terminal` |
| Gpg4win | `gpg4win` |
| Tailscale | `tailscale` |

## Non-Chocolatey Installs

| Tool | Method |
|------|--------|
| Node.js 22 | `nvm install 22` |
| Yarn | `npm install -g yarn` |
| gitego | `go install github.com/bgreenwell/gitego@main` |
