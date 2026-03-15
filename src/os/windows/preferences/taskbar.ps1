$ErrorActionPreference = "Stop"

$PREF_NAME    = "Taskbar"
$CHANGES_MADE = $false

Write-Host "Configuring $PREF_NAME..."

$AdvancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Helper: grant the current user SetValue rights on a registry key to unblock locked keys.
function Unlock-RegKey {
    param([string]$Path)
    try {
        $acl  = Get-Acl -Path $Path -ErrorAction Stop
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

        # Break inheritance and copy inherited ACEs as explicit entries so that
        # inherited Deny rules (which also override Allow) can be removed individually.
        $acl.SetAccessRuleProtection($true, $true)

        # Remove all explicit Deny ACEs for the current user — Deny always wins over Allow.
        $denyRules = $acl.Access | Where-Object {
            $_.IdentityReference.Value -eq $user -and
            $_.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Deny
        }
        foreach ($deny in $denyRules) {
            $acl.RemoveAccessRule($deny) | Out-Null
        }

        # Grant the current user SetValue rights.
        $allow = New-Object System.Security.AccessControl.RegistryAccessRule(
            $user,
            [System.Security.AccessControl.RegistryRights]::SetValue,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.SetAccessRule($allow)
        Set-Acl -Path $Path -AclObject $acl -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Helper: set a registry DWORD only if the value differs.
# On access-denied, attempts to unlock the key ACL and retries once.
function Set-RegDWord {
    param([string]$Path, [string]$Name, [int]$Value)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    $current = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -ne $current -and $current -eq $Value) { return }
    try {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord
        $script:CHANGES_MADE = $true
    } catch {
        if (Unlock-RegKey $Path) {
            try {
                Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord
                $script:CHANGES_MADE = $true
            } catch {
                Write-Host "  Note: Could not set $Name at $Path (access denied even after unlock, skipping)."
            }
        } else {
            Write-Host "  Note: Could not set $Name at $Path (access denied, skipping)."
        }
    }
}

# --- Hide Copilot button (Windows 11) ---
Set-RegDWord $AdvancedPath "ShowCopilotButton" 0
# Policy-level disable (more persistent across updates)
Set-RegDWord "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1

# --- Hide Widgets button (news/weather panel powered by Edge, Windows 11) ---
# Primary: TaskbarDa in Explorer\Advanced (may be policy-locked on some machines).
Set-RegDWord $AdvancedPath "TaskbarDa" 0
# Fallback 1: reg.exe uses a different code path and can bypass PowerShell ACL restrictions.
# Wrap in try/catch — reg.exe writes "Access is denied." to stderr which $ErrorActionPreference=Stop treats as a terminating error.
try {
    $regResult = reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f 2>&1
    if ($LASTEXITCODE -eq 0) { $CHANGES_MADE = $true }
} catch {
    # Access denied via reg.exe as well; ShellFeedsTaskbarViewMode fallback below will handle it.
}
# Fallback 2: ShellFeedsTaskbarViewMode in the Feeds key — an alternate path that hides
# the Widgets panel and is typically not subject to the same policy restrictions.
Set-RegDWord "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2

# --- Hide Task View button ---
Set-RegDWord $AdvancedPath "ShowTaskViewButton" 0

# --- Unpin Microsoft Edge from taskbar ---
# Two-pronged approach: remove the .lnk file (legacy/Win10) and use the Shell COM
# unpin verb (Windows 11 stores pins in a registry blob; the verb updates both).
$taskbarPinsDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$edgeLnk        = "$taskbarPinsDir\Microsoft Edge.lnk"
if (Test-Path $edgeLnk) {
    Remove-Item $edgeLnk -Force
    $CHANGES_MADE = $true
    Write-Host "  Removed Edge taskbar pin shortcut."
}
try {
    $edgeExe = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgeExe)) { $edgeExe = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe" }
    if (Test-Path $edgeExe) {
        $shell  = New-Object -ComObject Shell.Application
        $dir    = $shell.Namespace([System.IO.Path]::GetDirectoryName($edgeExe))
        $item   = $dir.ParseName([System.IO.Path]::GetFileName($edgeExe))
        $unpin  = $item.Verbs() | Where-Object { $_.Name -match "unpin" }
        if ($unpin) {
            $unpin | ForEach-Object { $_.DoIt() }
            $CHANGES_MADE = $true
            Write-Host "  Unpinned Microsoft Edge from taskbar (COM)."
        }
    }
} catch {
    # COM unpin not available on this Windows version; .lnk removal above is sufficient.
}

# Prevent Edge from auto-repinning itself to the taskbar after updates.
# Clears the Active Setup stub that triggers Edge's self-pin on login.
$edgeSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}"
try {
    if (Test-Path $edgeSetupKey) {
        $stub = (Get-ItemProperty -Path $edgeSetupKey -Name "StubPath" -ErrorAction SilentlyContinue).StubPath
        if ($stub) {
            Remove-ItemProperty -Path $edgeSetupKey -Name "StubPath" -Force
            $CHANGES_MADE = $true
            Write-Host "  Cleared Edge Active Setup auto-pin stub."
        }
    }
} catch {
    Write-Host "  Note: Could not clear Edge Active Setup stub (may need admin)."
}

# --- Restart Explorer to apply taskbar changes ---
if ($CHANGES_MADE) {
    Write-Host "  Restarting Explorer to apply taskbar changes..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1000
    Start-Process explorer.exe
    Write-Host "$PREF_NAME preferences applied."
    Write-Host "  Note: Copilot and Widgets button changes require a full system restart to take effect."
} else {
    Write-Host "$PREF_NAME already configured."
}
