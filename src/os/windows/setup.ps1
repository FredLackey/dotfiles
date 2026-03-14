$ErrorActionPreference = "Stop"

$ScriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallersDir  = "$ScriptDir\installers"
$PreferencesDir = "$ScriptDir\preferences"

# Collect names of any installers that fail so we can report them at the end.
$FailedInstallers = @()

Write-Host "Running Windows setup..."

# Check if a category is excluded via DOTFILES_EXCLUDE environment variable
# Usage: Is-Excluded "AI" returns $true if excluded
function Is-Excluded {
    param([string]$Category)
    $exclude = $env:DOTFILES_EXCLUDE
    if (-not $exclude) { return $false }
    $excludeUpper  = $exclude.ToUpper()
    $categoryUpper = $Category.ToUpper()
    return ",$excludeUpper," -like "*,$categoryUpper,*"
}

# Run an installer script
# Usage: Run-Installer "git.ps1" "DEV"
# Failures are caught and recorded; they do NOT abort the overall setup.
function Run-Installer {
    param(
        [string]$ScriptName,
        [string]$Category = ""
    )

    if ($Category -and (Is-Excluded $Category)) {
        Write-Host "--------------------------------------------------"
        Write-Host "Skipping installer (excluded category $Category): $ScriptName"
        return
    }

    $ScriptPath = "$InstallersDir\$ScriptName"
    if (-not (Test-Path $ScriptPath)) {
        Write-Host "WARNING: Installer script not found: $ScriptName"
        $script:FailedInstallers += $ScriptName
        return
    }

    Write-Host "--------------------------------------------------"
    Write-Host "Running installer: $ScriptName"
    try {
        & $ScriptPath
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            Write-Host "WARNING: $ScriptName exited with code $LASTEXITCODE"
            $script:FailedInstallers += $ScriptName
        }
    } catch {
        Write-Host "WARNING: $ScriptName failed: $_"
        $script:FailedInstallers += $ScriptName
    }
}

function Apply-Preferences {
    $PrefsScript = "$PreferencesDir\setup.ps1"
    if (Test-Path $PrefsScript) {
        try {
            & $PrefsScript
        } catch {
            Write-Host "WARNING: preferences/setup.ps1 failed: $_"
        }
    } else {
        Write-Host "No preferences script found, skipping."
    }
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Pre-flight: accept all winget source agreements (including msstore) up front
# so individual installers never hit the interactive agreement prompt.
# winget source update alone doesn't trigger msstore acceptance; winget list
# actually queries every source, which is what records the agreement.
Write-Host "Accepting winget source agreements..."
winget list --accept-source-agreements 2>&1 | Out-Null

Write-Host "Starting application installation..."

# Categories: SYSTEM, LANGUAGES, TERMINAL, DEV, DEVOPS, UTILS, MEDIA, SECURITY, AI, APPS, DESKTOP

# 1. Critical System Tools
Run-Installer "wsl.ps1"          "SYSTEM"
Run-Installer "git.ps1"          "SYSTEM"
Run-Installer "github-cli.ps1"   "DEV"

# 2. Languages & Runtimes
Run-Installer "nvm.ps1"          "LANGUAGES"
Run-Installer "node.ps1"         "LANGUAGES"
Run-Installer "bun.ps1"          "LANGUAGES"

# Reload PATH so npm-dependent installers can find node/npm
Refresh-Path

Run-Installer "yarn.ps1"              "LANGUAGES"
Run-Installer "npm-check-updates.ps1" "LANGUAGES"
Run-Installer "go.ps1"               "LANGUAGES"
Run-Installer "terraform.ps1"        "DEVOPS"

# 3. Shell Configuration
Run-Installer "shell-config.ps1" "SYSTEM"

# 4. Fonts & Prompt
Run-Installer "nerd-fonts.ps1"      "TERMINAL"
Run-Installer "starship.ps1"        "TERMINAL"
Run-Installer "starship-config.ps1" "TERMINAL"

# 5. Core CLI Tools
Run-Installer "gpg.ps1"       "UTILS"
Run-Installer "jq.ps1"        "UTILS"
Run-Installer "yq.ps1"        "UTILS"
Run-Installer "pandoc.ps1"    "UTILS"
Run-Installer "sharpkeys.ps1" "UTILS"
Run-Installer "yt-dlp.ps1"  "MEDIA"
Run-Installer "imagemagick.ps1" "MEDIA"
Run-Installer "nmap.ps1"    "SECURITY"
Run-Installer "aws-cli.ps1" "DEVOPS"

# 6. AI Tools
Run-Installer "gemini-cli.ps1" "AI"
Run-Installer "claude-code.ps1" "AI"
Run-Installer "cursor.ps1"     "AI"
Run-Installer "kiro.ps1"       "AI"

# 7. Editors & IDEs
Run-Installer "vscode.ps1"       "DEV"
Run-Installer "sublime-text.ps1" "DEV"

# 8. Applications & GUI Tools
Run-Installer "docker.ps1"         "DEVOPS"
Run-Installer "postman.ps1"        "DEV"
Run-Installer "dbeaver.ps1"        "DEV"
Run-Installer "studio-3t.ps1"      "DEV"
Run-Installer "drawio.ps1"         "DEV"
Run-Installer "beyond-compare.ps1" "DEV"
Run-Installer "slack.ps1"          "APPS"
Run-Installer "google-chrome.ps1"  "APPS"
Run-Installer "brave-browser.ps1"  "APPS"
Run-Installer "obsidian.ps1"       "APPS"
Run-Installer "telegram.ps1"       "APPS"
Run-Installer "termius.ps1"        "APPS"
Run-Installer "balena-etcher.ps1"  "APPS"

# Apply system preferences
Apply-Preferences

Write-Host ""
if ($FailedInstallers.Count -gt 0) {
    Write-Host "Setup complete with $($FailedInstallers.Count) failure(s):"
    foreach ($name in $FailedInstallers) {
        Write-Host "  - $name"
    }
    Write-Host "Open a new PowerShell window and re-run setup to retry failed installers."
} else {
    Write-Host "Setup complete. Open a new PowerShell window to activate the new shell configuration."
}
