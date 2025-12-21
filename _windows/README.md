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
- Administrator privileges
- Internet connection

## Usage

```powershell
# Run as Administrator
powershell -ExecutionPolicy Bypass -File setup.ps1

# Non-interactive mode
.\setup.ps1 -SkipConfirmation
```

## Configuration

Edit the `$IdentityConfig` section at the top of `setup.ps1`:

```powershell
$IdentityConfig = @{
    Name = "Your Name"
    ProjectsRoot = "C:\_"              # Root for project directories
    DefaultProfile = "personal"

    Identities = @(
        @{
            Profile      = "personal"
            Email        = "you@example.com"
            Username     = "YourGitHubUsername"
            SshKeyName   = "id_personal"
            Directory    = "YourName"          # Creates C:\_\YourName
            GpgSign      = $true
            SshHosts     = @(
                @{ Alias = "github.com"; HostName = "github.com"; Port = 22 }
            )
        }
        # Add more identities by copying the block above
    )
}
```

### Adding a New Identity

Copy an identity block and modify:

```powershell
@{
    Profile      = "work"
    Email        = "you@company.com"
    Username     = "WorkUsername"
    SshKeyName   = "id_work"
    Directory    = "CompanyName"
    GpgSign      = $true
    SshHosts     = @(
        @{ Alias = "github-work"; HostName = "github.com"; Port = 22 }
        @{ Alias = "gitlab.company.com"; HostName = "gitlab.company.com"; Port = 22 }
    )
}
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
