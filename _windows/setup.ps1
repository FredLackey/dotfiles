# setup.ps1 - Windows Development Environment Setup
# Run as Administrator: powershell -ExecutionPolicy Bypass -File setup.ps1

#Requires -RunAsAdministrator

param(
    [switch]$SkipConfirmation
)

# =============================================================================
# IDENTITY CONFIGURATION - Modify this section for your identities
# =============================================================================
# Each identity gets: SSH key, GPG key (if GpgSign=$true), gitego profile,
# project directory, and auto-switch rule.
#
# To add a new identity, copy an existing block and modify the values.
# =============================================================================

$IdentityConfig = @{
    # Your display name for Git commits
    Name = "Fred Lackey"

    # Root directory for all projects (gitego auto-switch maps subdirectories)
    # Common choices: "C:\_", "C:\Source", "$env:USERPROFILE\Source"
    ProjectsRoot = "C:\_"

    # Default gitego profile (must match a Profile name below)
    DefaultProfile = "personal"

    # Identities - add/remove/modify as needed
    # Each identity creates:
    #   - SSH key:     %USERPROFILE%\.ssh\{SshKeyName}
    #   - GPG key:     Linked to {Email} (if GpgSign = $true)
    #   - Directory:   {ProjectsRoot}\{Directory}
    #   - gitego:      Profile with auto-switch for the directory
    Identities = @(
        @{
            Profile      = "personal"
            Email        = "fred.lackey@gmail.com"
            Username     = "FredLackeyOfficial"
            SshKeyName   = "id_personal"
            Directory    = "FredLackey"         # Creates C:\_\FredLackey
            GpgSign      = $true
            # SSH host configurations for this identity
            SshHosts     = @(
                @{ Alias = "github.com"; HostName = "github.com"; Port = 22 }
                @{ Alias = "github-personal"; HostName = "github.com"; Port = 22 }
            )
        }
        # -------------------------------------------------------------------------
        # EXAMPLE: Add more identities by copying and modifying this block
        # -------------------------------------------------------------------------
        # @{
        #     Profile      = "acme"
        #     Email        = "you@acme.com"
        #     Username     = "YourAcmeUsername"
        #     SshKeyName   = "id_acme"
        #     Directory    = "Acme"             # Creates C:\_\Acme
        #     GpgSign      = $true
        #     SshHosts     = @(
        #         @{ Alias = "github-acme"; HostName = "github.com"; Port = 22 }
        #     )
        # }
        # -------------------------------------------------------------------------
    )
}

# =============================================================================
# END IDENTITY CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Package Configuration
# -----------------------------------------------------------------------------

$ChocolateyPackages = @(
    @{ Name = "Git for Windows"; Package = "git" },
    @{ Name = "nvm-windows"; Package = "nvm" },
    @{ Name = "Go"; Package = "golang" },
    @{ Name = "NeoVim"; Package = "neovim" },
    @{ Name = "Visual Studio Code"; Package = "vscode" },
    @{ Name = "jq"; Package = "jq" },
    @{ Name = "yq"; Package = "yq" },
    @{ Name = "Visual Studio Build Tools"; Package = "visualstudio2022buildtools" },
    @{ Name = "Google Chrome"; Package = "googlechrome"; IgnoreChecksum = $true },
    @{ Name = "Windows Terminal"; Package = "microsoft-windows-terminal" },
    @{ Name = "Gpg4win"; Package = "gpg4win" },
    @{ Name = "Tailscale"; Package = "tailscale" }
)

$NodeVersion = "22"
$GitegoRepo = "github.com/bgreenwell/gitego@main"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

function Write-Step {
    param([string]$Message)
    Write-Host "`n>> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "   [OK] $Message" -ForegroundColor Green
}

function Write-Skipped {
    param([string]$Message)
    Write-Host "   [SKIP] $Message" -ForegroundColor Yellow
}

function Write-Failure {
    param([string]$Message)
    Write-Host "   [FAIL] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "   $Message" -ForegroundColor Gray
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-ChocolateyPackageInstalled {
    param([string]$Package)
    $result = choco list --local-only --exact $Package 2>$null
    return $result -match $Package
}

function Refresh-Environment {
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Refresh NVM environment variables
    $nvmHome = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "User")
    $nvmSymlink = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User")

    if ($nvmHome) {
        $env:NVM_HOME = $nvmHome
        # Add NVM_HOME to path if not already there
        if ($env:Path -notlike "*$nvmHome*") {
            $env:Path = "$nvmHome;$env:Path"
        }
    }
    if ($nvmSymlink) {
        $env:NVM_SYMLINK = $nvmSymlink
        # Add NVM_SYMLINK to path if not already there
        if ($env:Path -notlike "*$nvmSymlink*") {
            $env:Path = "$nvmSymlink;$env:Path"
        }
    }

    # Refresh GOPATH
    $goPath = [System.Environment]::GetEnvironmentVariable("GOPATH", "User")
    if ($goPath) {
        $env:GOPATH = $goPath
    }
}

function Add-ToUserPath {
    param([string]$PathToAdd)

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PathToAdd*") {
        $newPath = "$currentPath;$PathToAdd"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$env:Path;$PathToAdd"
        return $true
    }
    return $false
}

# -----------------------------------------------------------------------------
# Identity Setup Functions
# -----------------------------------------------------------------------------

function Initialize-SshDirectory {
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    return $sshDir
}

function New-SshKey {
    param(
        [string]$KeyName,
        [string]$Email
    )

    $sshDir = Initialize-SshDirectory
    $keyPath = "$sshDir\$KeyName"

    if (Test-Path $keyPath) {
        Write-Skipped "SSH key '$KeyName' already exists"
        return @{ Success = $true; Path = $keyPath; Skipped = $true }
    }

    try {
        # Generate ED25519 key with empty passphrase for automation
        $output = ssh-keygen -t ed25519 -C $Email -f $keyPath -N '""' -q 2>&1
        if (Test-Path $keyPath) {
            Write-Success "SSH key '$KeyName' generated"
            return @{ Success = $true; Path = $keyPath; Skipped = $false }
        }
        else {
            Write-Failure "SSH key '$KeyName' generation failed"
            Write-Info ($output | Out-String)
            return @{ Success = $false; Path = $null; Skipped = $false }
        }
    }
    catch {
        Write-Failure "SSH key '$KeyName' generation failed: $_"
        return @{ Success = $false; Path = $null; Skipped = $false }
    }
}

function New-GpgKey {
    param(
        [string]$Name,
        [string]$Email
    )

    # Check if GPG key already exists for this email
    $existingKey = gpg --list-secret-keys --keyid-format=long $Email 2>$null
    if ($existingKey) {
        Write-Skipped "GPG key for '$Email' already exists"
        $keyId = Get-GpgKeyId -Email $Email
        return @{ Success = $true; KeyId = $keyId; Skipped = $true }
    }

    try {
        # Generate GPG key in batch mode with no passphrase
        # Using quick-generate-key for simplicity
        Write-Info "Generating GPG key for $Email (this may take a moment)..."
        $output = gpg --batch --passphrase "" --quick-generate-key "$Name <$Email>" ed25519 sign 1y 2>&1

        if ($LASTEXITCODE -eq 0) {
            $keyId = Get-GpgKeyId -Email $Email
            if ($keyId) {
                Write-Success "GPG key generated for '$Email' (Key ID: $keyId)"
                return @{ Success = $true; KeyId = $keyId; Skipped = $false }
            }
        }

        Write-Failure "GPG key generation failed for '$Email'"
        Write-Info ($output | Out-String)
        return @{ Success = $false; KeyId = $null; Skipped = $false }
    }
    catch {
        Write-Failure "GPG key generation failed for '$Email': $_"
        return @{ Success = $false; KeyId = $null; Skipped = $false }
    }
}

function Get-GpgKeyId {
    param([string]$Email)

    try {
        $output = gpg --list-secret-keys --keyid-format=long $Email 2>$null
        if ($output) {
            # Extract key ID from output like "sec   ed25519/ABC123DEF4567890 2024-01-15"
            $match = [regex]::Match(($output | Out-String), '(ed25519|rsa\d+)/([A-F0-9]+)')
            if ($match.Success) {
                return $match.Groups[2].Value
            }
        }
    }
    catch { }
    return $null
}

function New-SshConfig {
    Write-Step "Generating SSH config"

    $sshDir = Initialize-SshDirectory
    $configPath = "$sshDir\config"

    # Build SSH config content from identities
    $configContent = @"
# SSH Config - Generated by setup.ps1
# Regenerate by running setup.ps1 again (will overwrite this file)

"@

    $processedHosts = @{}

    foreach ($identity in $IdentityConfig.Identities) {
        $keyPath = "~/.ssh/$($identity.SshKeyName)"

        $configContent += @"
# ------------------------------------------------------------------------------
# $($identity.Profile)
# ------------------------------------------------------------------------------

"@
        foreach ($sshHost in $identity.SshHosts) {
            # Skip if we've already processed this alias
            if ($processedHosts.ContainsKey($sshHost.Alias)) {
                continue
            }
            $processedHosts[$sshHost.Alias] = $true

            $configContent += @"
Host $($sshHost.Alias)
    HostName $($sshHost.HostName)
    Port $($sshHost.Port)
    User git
    IdentityFile $keyPath
    IdentitiesOnly yes

"@
        }
    }

    try {
        $configContent | Out-File -FilePath $configPath -Encoding ASCII -Force
        Write-Success "SSH config written to $configPath"
        return $true
    }
    catch {
        Write-Failure "Failed to write SSH config: $_"
        return $false
    }
}

function Start-SshAgent {
    Write-Step "Configuring SSH Agent"

    try {
        # Check if ssh-agent service exists and configure it
        $service = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.StartType -ne 'Automatic') {
                Set-Service -Name ssh-agent -StartupType Automatic
                Write-Success "SSH Agent set to start automatically"
            }
            else {
                Write-Skipped "SSH Agent already set to automatic"
            }

            if ($service.Status -ne 'Running') {
                Start-Service ssh-agent
                Write-Success "SSH Agent started"
            }
            else {
                Write-Skipped "SSH Agent already running"
            }
            return $true
        }
        else {
            Write-Failure "SSH Agent service not found"
            return $false
        }
    }
    catch {
        Write-Failure "Failed to configure SSH Agent: $_"
        return $false
    }
}

function Add-SshKeysToAgent {
    Write-Step "Adding SSH keys to agent"

    $sshDir = "$env:USERPROFILE\.ssh"
    $addedAny = $false

    foreach ($identity in $IdentityConfig.Identities) {
        $keyPath = "$sshDir\$($identity.SshKeyName)"
        if (Test-Path $keyPath) {
            try {
                # Check if key is already in agent
                $existingKeys = ssh-add -l 2>$null
                $keyFingerprint = ssh-keygen -lf $keyPath 2>$null

                if ($existingKeys -and $keyFingerprint) {
                    $fp = ($keyFingerprint -split ' ')[1]
                    if ($existingKeys -match [regex]::Escape($fp)) {
                        Write-Skipped "$($identity.SshKeyName) already in agent"
                        continue
                    }
                }

                $output = ssh-add $keyPath 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$($identity.SshKeyName) added to agent"
                    $addedAny = $true
                }
                else {
                    Write-Failure "Failed to add $($identity.SshKeyName): $output"
                }
            }
            catch {
                Write-Failure "Failed to add $($identity.SshKeyName): $_"
            }
        }
    }

    return $true
}

function Set-GitGlobalConfig {
    Write-Step "Configuring Git global settings"

    try {
        # Find GPG path
        $gpgPath = "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
        if (-not (Test-Path $gpgPath)) {
            $gpgPath = "C:\Program Files\GnuPG\bin\gpg.exe"
        }
        if (-not (Test-Path $gpgPath)) {
            $gpgCmd = Get-Command gpg -ErrorAction SilentlyContinue
            if ($gpgCmd) { $gpgPath = $gpgCmd.Source }
        }

        if (Test-Path $gpgPath) {
            git config --global gpg.program $gpgPath
            Write-Success "Git GPG program set to $gpgPath"
        }
        else {
            Write-Failure "GPG not found - commit signing may not work"
        }

        # Set credential helper to gitego
        git config --global credential.helper ""
        git config --global --add credential.helper "!gitego credential"
        Write-Success "Git credential helper set to gitego"

        # Enable commit signing
        git config --global commit.gpgsign true
        Write-Success "Git commit signing enabled"

        # Prevent Git from guessing identity
        git config --global user.useConfigOnly true
        Write-Success "Git useConfigOnly enabled"

        # Set default branch
        git config --global init.defaultBranch main
        Write-Success "Git default branch set to main"

        return $true
    }
    catch {
        Write-Failure "Failed to configure Git: $_"
        return $false
    }
}

function New-GitegoProfiles {
    Write-Step "Creating gitego profiles"

    Refresh-Environment

    if (-not (Test-CommandExists "gitego")) {
        Write-Failure "gitego not found - skipping profile creation"
        return $false
    }

    $sshDir = "$env:USERPROFILE\.ssh"
    $createdAny = $false

    foreach ($identity in $IdentityConfig.Identities) {
        $profile = $identity.Profile

        # Check if profile already exists
        $existingProfiles = gitego list 2>$null
        if ($existingProfiles -match "\b$profile\b") {
            Write-Skipped "gitego profile '$profile' already exists"
            continue
        }

        $keyPath = "$sshDir\$($identity.SshKeyName)"

        # Build gitego add command
        $gitegoArgs = @(
            "add", $profile,
            "--name", $IdentityConfig.Name,
            "--email", $identity.Email,
            "--username", $identity.Username,
            "--ssh-key", $keyPath
        )

        # Add GPG signing key if enabled and available
        if ($identity.GpgSign) {
            $gpgKeyId = Get-GpgKeyId -Email $identity.Email
            if ($gpgKeyId) {
                $gitegoArgs += @("--signing-key", $gpgKeyId)
            }
        }

        try {
            $output = & gitego @gitegoArgs 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "gitego profile '$profile' created"
                $createdAny = $true
            }
            else {
                Write-Failure "gitego profile '$profile' creation failed"
                Write-Info ($output | Out-String)
            }
        }
        catch {
            Write-Failure "gitego profile '$profile' creation failed: $_"
        }
    }

    # Set default profile
    if ($IdentityConfig.DefaultProfile) {
        try {
            gitego use $IdentityConfig.DefaultProfile 2>$null
            Write-Success "Default gitego profile set to '$($IdentityConfig.DefaultProfile)'"
        }
        catch {
            Write-Info "Could not set default profile"
        }
    }

    return $true
}

function New-ProjectDirectories {
    Write-Step "Creating project directories"

    $root = $IdentityConfig.ProjectsRoot

    # Create root if needed
    if (-not (Test-Path $root)) {
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        Write-Success "Created $root"
    }
    else {
        Write-Skipped "$root already exists"
    }

    # Create subdirectory for each identity
    foreach ($identity in $IdentityConfig.Identities) {
        $dir = "$root\$($identity.Directory)"
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Success "Created $dir"
        }
        else {
            Write-Skipped "$dir already exists"
        }
    }

    return $true
}

function Set-GitegoAutoSwitch {
    Write-Step "Configuring gitego auto-switch rules"

    Refresh-Environment

    if (-not (Test-CommandExists "gitego")) {
        Write-Failure "gitego not found - skipping auto-switch setup"
        return $false
    }

    $root = $IdentityConfig.ProjectsRoot

    foreach ($identity in $IdentityConfig.Identities) {
        $dir = "$root\$($identity.Directory)\"
        $profile = $identity.Profile

        try {
            $output = gitego auto $dir $profile 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Auto-switch: $dir -> $profile"
            }
            else {
                # gitego auto might return non-zero if rule exists
                Write-Skipped "Auto-switch rule for '$profile' (may already exist)"
            }
        }
        catch {
            Write-Info "Could not set auto-switch for '$profile'"
        }
    }

    return $true
}

function Show-PublicKeys {
    Write-Host "`n" -NoNewline
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host "                    PUBLIC KEYS FOR REGISTRATION              " -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Register these keys with your Git providers (GitHub, GitLab, etc.)" -ForegroundColor Yellow
    Write-Host ""

    $sshDir = "$env:USERPROFILE\.ssh"

    foreach ($identity in $IdentityConfig.Identities) {
        Write-Host "--- $($identity.Profile) ($($identity.Email)) ---" -ForegroundColor Cyan

        # SSH public key
        $sshPubPath = "$sshDir\$($identity.SshKeyName).pub"
        if (Test-Path $sshPubPath) {
            Write-Host "`nSSH Public Key:" -ForegroundColor Green
            Get-Content $sshPubPath | Write-Host -ForegroundColor Gray
        }

        # GPG public key
        if ($identity.GpgSign) {
            $gpgKeyId = Get-GpgKeyId -Email $identity.Email
            if ($gpgKeyId) {
                Write-Host "`nGPG Public Key (Key ID: $gpgKeyId):" -ForegroundColor Green
                gpg --armor --export $gpgKeyId 2>$null | Write-Host -ForegroundColor Gray
            }
        }

        Write-Host ""
    }

    Write-Host "------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Registration URLs:" -ForegroundColor Yellow
    Write-Host "   GitHub:    https://github.com/settings/keys" -ForegroundColor Gray
    Write-Host "   GitLab:    https://gitlab.com/-/profile/keys" -ForegroundColor Gray
    Write-Host "   Bitbucket: https://bitbucket.org/account/settings/ssh-keys/" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Gray
}

function Setup-Identities {
    Write-Step "Setting up identities"

    $results = @()

    # Generate SSH keys for each identity
    Write-Step "Generating SSH keys"
    foreach ($identity in $IdentityConfig.Identities) {
        $result = New-SshKey -KeyName $identity.SshKeyName -Email $identity.Email
        $results += @{ Name = "SSH: $($identity.SshKeyName)"; Success = $result.Success }
    }

    # Generate GPG keys for identities that need signing
    Write-Step "Generating GPG keys"
    foreach ($identity in $IdentityConfig.Identities) {
        if ($identity.GpgSign) {
            $result = New-GpgKey -Name $IdentityConfig.Name -Email $identity.Email
            $results += @{ Name = "GPG: $($identity.Email)"; Success = $result.Success }
        }
    }

    # Generate SSH config
    $sshConfigResult = New-SshConfig
    $results += @{ Name = "SSH Config"; Success = $sshConfigResult }

    # Start and configure SSH agent
    $agentResult = Start-SshAgent
    $results += @{ Name = "SSH Agent"; Success = $agentResult }

    # Add keys to agent
    $addKeysResult = Add-SshKeysToAgent
    $results += @{ Name = "SSH Keys in Agent"; Success = $addKeysResult }

    # Configure Git global settings
    $gitConfigResult = Set-GitGlobalConfig
    $results += @{ Name = "Git Global Config"; Success = $gitConfigResult }

    # Create project directories
    $dirsResult = New-ProjectDirectories
    $results += @{ Name = "Project Directories"; Success = $dirsResult }

    # Create gitego profiles
    $profilesResult = New-GitegoProfiles
    $results += @{ Name = "gitego Profiles"; Success = $profilesResult }

    # Set up auto-switch rules
    $autoSwitchResult = Set-GitegoAutoSwitch
    $results += @{ Name = "gitego Auto-Switch"; Success = $autoSwitchResult }

    return $results
}

# -----------------------------------------------------------------------------
# Prerequisite Checks
# -----------------------------------------------------------------------------

function Test-Prerequisites {
    Write-Step "Checking prerequisites"

    # Check Windows version (Windows 10 build 19041+ or Windows 11)
    $osVersion = [System.Environment]::OSVersion.Version
    $buildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber

    if ([int]$buildNumber -lt 19041) {
        Write-Failure "Windows 10 (build 19041+) or Windows 11 required. Current build: $buildNumber"
        return $false
    }
    Write-Success "Windows version OK (build $buildNumber)"

    # Check internet connectivity
    try {
        $null = Invoke-WebRequest -Uri "https://chocolatey.org" -UseBasicParsing -TimeoutSec 10
        Write-Success "Internet connectivity OK"
    }
    catch {
        Write-Failure "No internet connection detected"
        return $false
    }

    return $true
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

function Install-Chocolatey {
    Write-Step "Installing Chocolatey"

    if (Test-CommandExists "choco") {
        Write-Skipped "Chocolatey already installed"
        return $true
    }

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Refresh-Environment
        Write-Success "Chocolatey installed"
        return $true
    }
    catch {
        Write-Failure "Failed to install Chocolatey: $_"
        return $false
    }
}

function Install-ChocolateyPackage {
    param(
        [string]$Name,
        [string]$Package,
        [bool]$IgnoreChecksum = $false
    )

    if (Test-ChocolateyPackageInstalled $Package) {
        Write-Skipped "$Name already installed"
        return $true
    }

    try {
        $chocoArgs = @("install", $Package, "-y", "--no-progress")
        if ($IgnoreChecksum) {
            $chocoArgs += "--ignore-checksums"
            Write-Info "$($Name): using --ignore-checksums (downloads from official source)"
        }

        $output = & choco @chocoArgs 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed"
            return $true
        }
        else {
            Write-Failure "$Name installation failed"
            Write-Info ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-Failure "$Name installation failed: $_"
        return $false
    }
}

function Install-ChocolateyPackages {
    Write-Step "Installing Chocolatey packages"

    $results = @()
    foreach ($pkg in $ChocolateyPackages) {
        $ignoreChecksum = if ($pkg.IgnoreChecksum) { $true } else { $false }
        $success = Install-ChocolateyPackage -Name $pkg.Name -Package $pkg.Package -IgnoreChecksum $ignoreChecksum
        $results += @{ Name = $pkg.Name; Success = $success }
    }

    Refresh-Environment
    return $results
}

function Install-NodeWithNvm {
    Write-Step "Installing Node.js $NodeVersion via nvm"

    Refresh-Environment

    # Find nvm.exe - check multiple possible locations
    $nvmPath = $null
    $possiblePaths = @(
        "$env:NVM_HOME\nvm.exe",
        "$env:USERPROFILE\AppData\Roaming\nvm\nvm.exe",
        "$env:ProgramFiles\nvm\nvm.exe",
        "C:\ProgramData\nvm\nvm.exe"
    )

    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            $nvmPath = $path
            Write-Info "Found nvm at: $nvmPath"
            break
        }
    }

    # Also try finding nvm in PATH
    if (-not $nvmPath) {
        $nvmCmd = Get-Command "nvm" -ErrorAction SilentlyContinue
        if ($nvmCmd) {
            $nvmPath = $nvmCmd.Source
            Write-Info "Found nvm in PATH: $nvmPath"
        }
    }

    if (-not $nvmPath) {
        Write-Failure "nvm not found. Please restart PowerShell and run this script again."
        Write-Info "Searched locations:"
        foreach ($path in $possiblePaths) {
            if ($path) { Write-Info "  - $path" }
        }
        return $false
    }

    try {
        # Install Node version
        Write-Info "Running: nvm install $NodeVersion"
        $output = & $nvmPath install $NodeVersion 2>&1
        Write-Info ($output | Out-String)

        # Use the installed version
        Write-Info "Running: nvm use $NodeVersion"
        $output = & $nvmPath use $NodeVersion 2>&1
        Write-Info ($output | Out-String)

        Refresh-Environment

        # Verify installation
        if (Test-CommandExists "node") {
            $installedVersion = node --version
            Write-Success "Node.js $installedVersion installed"
            return $true
        }
        else {
            Write-Failure "Node.js installation could not be verified"
            Write-Info "You may need to restart PowerShell and run 'nvm use $NodeVersion'"
            return $false
        }
    }
    catch {
        Write-Failure "Failed to install Node.js: $_"
        return $false
    }
}

function Install-Yarn {
    Write-Step "Installing Yarn via npm"

    Refresh-Environment

    # Check if Yarn is already installed
    if (Test-CommandExists "yarn") {
        Write-Skipped "Yarn already installed"
        return $true
    }

    # Find npm - check NVM_SYMLINK first, then PATH
    $npmPath = $null
    if ($env:NVM_SYMLINK -and (Test-Path "$env:NVM_SYMLINK\npm.cmd")) {
        $npmPath = "$env:NVM_SYMLINK\npm.cmd"
        Write-Info "Found npm at: $npmPath"
    }
    elseif (Test-CommandExists "npm") {
        $npmPath = "npm"
    }

    if (-not $npmPath) {
        Write-Failure "npm not found. Node.js may not be properly installed."
        Write-Info "Run 'nvm use $NodeVersion' and try again, or restart PowerShell."
        return $false
    }

    try {
        Write-Info "Running: npm install -g yarn"
        $output = & $npmPath install -g yarn 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Yarn installed"
            return $true
        }
        else {
            Write-Failure "Yarn installation failed"
            Write-Info ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-Failure "Failed to install Yarn: $_"
        return $false
    }
}

function Install-Gitego {
    Write-Step "Installing gitego via go install"

    Refresh-Environment

    # Check if gitego is already installed
    if (Test-CommandExists "gitego") {
        Write-Skipped "gitego already installed"
        return $true
    }

    # Find go.exe - check common locations
    $goPath = $null
    $possiblePaths = @(
        "C:\Program Files\Go\bin\go.exe",
        "C:\Go\bin\go.exe",
        "$env:USERPROFILE\go\bin\go.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $goPath = $path
            Write-Info "Found Go at: $goPath"
            break
        }
    }

    if (-not $goPath -and (Test-CommandExists "go")) {
        $goPath = "go"
    }

    if (-not $goPath) {
        Write-Failure "Go not found. Please restart PowerShell and run this script again."
        return $false
    }

    try {
        # Set GOPATH if not set
        if (-not $env:GOPATH) {
            $env:GOPATH = "$env:USERPROFILE\go"
        }

        Write-Info "GOPATH: $env:GOPATH"
        Write-Info "Running: go install $GitegoRepo"

        $output = & $goPath install $GitegoRepo 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "gitego installed to $env:GOPATH\bin"
            return $true
        }
        else {
            Write-Failure "gitego installation failed"
            Write-Info ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-Failure "Failed to install gitego: $_"
        return $false
    }
}

function Add-GoBinToPath {
    Write-Step "Adding Go bin to PATH"

    $goBinPath = "$env:USERPROFILE\go\bin"

    if (Add-ToUserPath $goBinPath) {
        Write-Success "Added $goBinPath to PATH"
    }
    else {
        Write-Skipped "$goBinPath already in PATH"
    }

    return $true
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

function Show-Summary {
    param(
        [array]$Results,
        [switch]$ShowKeys
    )

    Write-Host "`n" -NoNewline
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    Installation Summary                      " -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    $succeeded = @()
    $failed = @()

    foreach ($result in $Results) {
        if ($result.Success) {
            $succeeded += $result.Name
        }
        else {
            $failed += $result.Name
        }
    }

    if ($succeeded.Count -gt 0) {
        Write-Host "`nSuccessfully completed:" -ForegroundColor Green
        foreach ($item in $succeeded) {
            Write-Host "   - $item" -ForegroundColor Green
        }
    }

    if ($failed.Count -gt 0) {
        Write-Host "`nFailed:" -ForegroundColor Red
        foreach ($item in $failed) {
            Write-Host "   - $item" -ForegroundColor Red
        }
    }

    Write-Host "`n------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Remaining manual steps:" -ForegroundColor Yellow
    Write-Host "   1. Restart PowerShell (or your terminal)" -ForegroundColor Gray
    Write-Host "   2. Run 'nvm use $NodeVersion' to activate Node.js" -ForegroundColor Gray
    Write-Host "   3. Register SSH and GPG public keys with Git providers" -ForegroundColor Gray
    Write-Host "      (see PUBLIC KEYS section above)" -ForegroundColor Gray
    Write-Host "   4. Test SSH connections:" -ForegroundColor Gray
    foreach ($identity in $IdentityConfig.Identities) {
        $firstHost = $identity.SshHosts[0].Alias
        Write-Host "      ssh -T git@$firstHost" -ForegroundColor DarkGray
    }
    Write-Host "   5. Verify gitego: gitego list" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Gray

    if ($failed.Count -gt 0) {
        Write-Host "`nSome steps failed. You may need to:" -ForegroundColor Yellow
        Write-Host "   - Restart PowerShell and re-run this script" -ForegroundColor Gray
        Write-Host "   - Install failed packages manually" -ForegroundColor Gray
    }

    Write-Host ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

function Main {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "         Windows Development Environment Setup               " -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  1. Install development tools:" -ForegroundColor Yellow
    Write-Host "     - Chocolatey, Git, nvm-windows, Node.js $NodeVersion, Yarn" -ForegroundColor Gray
    Write-Host "     - Go, gitego, NeoVim, VSCode, jq, yq" -ForegroundColor Gray
    Write-Host "     - VS Build Tools, Chrome, Windows Terminal" -ForegroundColor Gray
    Write-Host "     - Gpg4win, Tailscale" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Configure identities:" -ForegroundColor Yellow
    foreach ($identity in $IdentityConfig.Identities) {
        $gpgNote = if ($identity.GpgSign) { " + GPG" } else { "" }
        Write-Host "     - $($identity.Profile): $($identity.Email) (SSH$gpgNote)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "  3. Set up:" -ForegroundColor Yellow
    Write-Host "     - SSH keys and config" -ForegroundColor Gray
    Write-Host "     - GPG signing keys (no passphrase for automation)" -ForegroundColor Gray
    Write-Host "     - gitego profiles with auto-switch rules" -ForegroundColor Gray
    Write-Host "     - Project directories in $($IdentityConfig.ProjectsRoot)" -ForegroundColor Gray
    Write-Host ""

    if (-not $SkipConfirmation) {
        $confirm = Read-Host "Continue? (Y/n)"
        if ($confirm -eq "n" -or $confirm -eq "N") {
            Write-Host "Aborted." -ForegroundColor Yellow
            exit 0
        }
    }

    # Track all results
    $allResults = @()

    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "`nPrerequisite check failed. Exiting." -ForegroundColor Red
        exit 1
    }

    # -------------------------------------------------------------------------
    # Phase 1: Install development tools
    # -------------------------------------------------------------------------

    # Install Chocolatey
    $chocoResult = Install-Chocolatey
    $allResults += @{ Name = "Chocolatey"; Success = $chocoResult }

    if (-not $chocoResult) {
        Write-Host "`nCannot continue without Chocolatey. Exiting." -ForegroundColor Red
        exit 1
    }

    # Install Chocolatey packages
    $pkgResults = Install-ChocolateyPackages
    $allResults += $pkgResults

    # Install Node.js via nvm
    $nodeResult = Install-NodeWithNvm
    $allResults += @{ Name = "Node.js $NodeVersion"; Success = $nodeResult }

    # Install Yarn via npm
    $yarnResult = Install-Yarn
    $allResults += @{ Name = "Yarn"; Success = $yarnResult }

    # Install gitego via go
    $gitegoResult = Install-Gitego
    $allResults += @{ Name = "gitego"; Success = $gitegoResult }

    # Add Go bin to PATH
    $pathResult = Add-GoBinToPath
    $allResults += @{ Name = "Go bin PATH"; Success = $pathResult }

    # -------------------------------------------------------------------------
    # Phase 2: Set up identities (SSH, GPG, gitego)
    # -------------------------------------------------------------------------

    $identityResults = Setup-Identities
    $allResults += $identityResults

    # -------------------------------------------------------------------------
    # Show results
    # -------------------------------------------------------------------------

    # Show public keys for registration
    Show-PublicKeys

    # Show summary
    Show-Summary -Results $allResults
}

# Run main
Main
