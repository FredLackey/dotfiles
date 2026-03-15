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
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            $user,
            [System.Security.AccessControl.RegistryRights]::SetValue,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.SetAccessRule($rule)
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
Set-RegDWord $AdvancedPath "TaskbarDa" 0

# --- Hide Task View button ---
Set-RegDWord $AdvancedPath "ShowTaskViewButton" 0

# --- Unpin Microsoft Edge from taskbar ---
# Taskbar pins are stored as .lnk shortcuts in the User Pinned folder.
$taskbarPinsDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$edgeLnk        = "$taskbarPinsDir\Microsoft Edge.lnk"
if (Test-Path $edgeLnk) {
    Remove-Item $edgeLnk -Force
    $CHANGES_MADE = $true
    Write-Host "  Unpinned Microsoft Edge from taskbar."
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
} else {
    Write-Host "$PREF_NAME already configured."
}
