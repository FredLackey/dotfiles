# setup.ps1 - Windows Development Environment Setup
# Run as Administrator: powershell -ExecutionPolicy Bypass -File setup.ps1

#Requires -RunAsAdministrator

param(
    [switch]$SkipConfirmation
)

# -----------------------------------------------------------------------------
# Configuration
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
    @{ Name = "Google Chrome"; Package = "googlechrome" },
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

function Refresh-EnvironmentPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
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
        Refresh-EnvironmentPath
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
        [string]$Package
    )

    if (Test-ChocolateyPackageInstalled $Package) {
        Write-Skipped "$Name already installed"
        return $true
    }

    try {
        $output = choco install $Package -y --no-progress 2>&1
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
        $success = Install-ChocolateyPackage -Name $pkg.Name -Package $pkg.Package
        $results += @{ Name = $pkg.Name; Success = $success }
    }

    Refresh-EnvironmentPath
    return $results
}

function Install-NodeWithNvm {
    Write-Step "Installing Node.js $NodeVersion via nvm"

    Refresh-EnvironmentPath

    # Check if nvm is available
    $nvmPath = "$env:USERPROFILE\AppData\Roaming\nvm\nvm.exe"
    if (-not (Test-Path $nvmPath)) {
        # Try to find nvm in PATH
        if (-not (Test-CommandExists "nvm")) {
            Write-Failure "nvm not found. Please restart PowerShell and run this script again."
            return $false
        }
    }

    try {
        # Install Node version
        $output = & $nvmPath install $NodeVersion 2>&1
        Write-Info "nvm install output: $output"

        # Use the installed version
        $output = & $nvmPath use $NodeVersion 2>&1
        Write-Info "nvm use output: $output"

        Refresh-EnvironmentPath

        # Verify installation
        if (Test-CommandExists "node") {
            $nodeVersion = node --version
            Write-Success "Node.js $nodeVersion installed"
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

    Refresh-EnvironmentPath

    if (-not (Test-CommandExists "npm")) {
        Write-Failure "npm not found. Node.js may not be properly installed."
        return $false
    }

    try {
        $output = npm install -g yarn 2>&1
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

    Refresh-EnvironmentPath

    if (-not (Test-CommandExists "go")) {
        Write-Failure "Go not found. Please restart PowerShell and run this script again."
        return $false
    }

    try {
        $env:GOPATH = "$env:USERPROFILE\go"
        $output = go install $GitegoRepo 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "gitego installed"
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
    param([array]$Results)

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
        Write-Host "`nSuccessfully installed:" -ForegroundColor Green
        foreach ($item in $succeeded) {
            Write-Host "   - $item" -ForegroundColor Green
        }
    }

    if ($failed.Count -gt 0) {
        Write-Host "`nFailed to install:" -ForegroundColor Red
        foreach ($item in $failed) {
            Write-Host "   - $item" -ForegroundColor Red
        }
    }

    Write-Host "`n------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Post-installation steps:" -ForegroundColor Yellow
    Write-Host "   1. Restart PowerShell (or your terminal)" -ForegroundColor Gray
    Write-Host "   2. Run 'nvm use $NodeVersion' to activate Node.js" -ForegroundColor Gray
    Write-Host "   3. Configure Git: git config --global user.name 'Your Name'" -ForegroundColor Gray
    Write-Host "   4. Configure Git: git config --global user.email 'you@email.com'" -ForegroundColor Gray
    Write-Host "   5. Configure gitego profiles (see gitego --help)" -ForegroundColor Gray
    Write-Host "   6. Import GPG keys if needed" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Gray

    if ($failed.Count -gt 0) {
        Write-Host "`nSome installations failed. You may need to:" -ForegroundColor Yellow
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
    Write-Host "This script will install:" -ForegroundColor Gray
    Write-Host "   - Chocolatey (package manager)" -ForegroundColor Gray
    Write-Host "   - Git for Windows (with Git Bash)" -ForegroundColor Gray
    Write-Host "   - nvm-windows, Node.js $NodeVersion, Yarn" -ForegroundColor Gray
    Write-Host "   - Go, gitego" -ForegroundColor Gray
    Write-Host "   - NeoVim, Visual Studio Code" -ForegroundColor Gray
    Write-Host "   - jq, yq" -ForegroundColor Gray
    Write-Host "   - Visual Studio Build Tools" -ForegroundColor Gray
    Write-Host "   - Google Chrome" -ForegroundColor Gray
    Write-Host "   - Windows Terminal" -ForegroundColor Gray
    Write-Host "   - Gpg4win" -ForegroundColor Gray
    Write-Host "   - Tailscale" -ForegroundColor Gray
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

    # Show summary
    Show-Summary -Results $allResults
}

# Run main
Main
