$ErrorActionPreference = "Stop"

$PREF_NAME    = "OneDrive Removal"
$CHANGES_MADE = $false

Write-Host "Configuring $PREF_NAME..."

# 1. CHECK - Skip if OneDrive is already gone
$setupExe = "$env:SystemRoot\System32\OneDriveSetup.exe"
$oneDriveExe = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"

if (-not (Test-Path $setupExe) -and -not (Test-Path $oneDriveExe)) {
    Write-Host "$PREF_NAME: OneDrive is not installed, nothing to do."
    # Still apply the policy to prevent future reinstallation
} else {

    # 2. Kill running OneDrive process before uninstalling
    $proc = Get-Process OneDrive -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Stopping OneDrive process..."
        Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
    }

    # 3. Uninstall via the official setup executable
    if (Test-Path $setupExe) {
        Write-Host "  Running OneDrive uninstaller..."
        Start-Process -FilePath $setupExe -ArgumentList "/uninstall /allusers" -Wait -ErrorAction SilentlyContinue
        $CHANGES_MADE = $true
    }

    # 4. Remove leftover shell namespace extensions (Explorer sidebar entry)
    $clsid = "{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    @(
        "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid",
        "Registry::HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
            $CHANGES_MADE = $true
        }
    }

    # 5. Remove OneDrive startup run key
    $runKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    if ((Get-ItemProperty -Path $runKey -Name "OneDrive" -ErrorAction SilentlyContinue)) {
        Remove-ItemProperty -Path $runKey -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        $CHANGES_MADE = $true
    }

    # 6. Restore shell folder redirections back to local paths
    #    (OneDrive sometimes redirects Documents, Desktop, Pictures to cloud folders)
    $shellFolders = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    $redirects = @{
        "Personal"    = "$env:USERPROFILE\Documents"
        "Desktop"     = "$env:USERPROFILE\Desktop"
        "My Pictures" = "$env:USERPROFILE\Pictures"
        "My Music"    = "$env:USERPROFILE\Music"
        "My Video"    = "$env:USERPROFILE\Videos"
    }
    foreach ($entry in $redirects.GetEnumerator()) {
        $current = (Get-ItemProperty -Path $shellFolders -Name $entry.Key -ErrorAction SilentlyContinue).($entry.Key)
        if ($current -and $current -like "*OneDrive*") {
            Set-ItemProperty -Path $shellFolders -Name $entry.Key -Value $entry.Value -ErrorAction SilentlyContinue
            $CHANGES_MADE = $true
        }
    }

    # 7. Remove OneDrive data and cache folders
    @(
        "$env:USERPROFILE\OneDrive",
        "$env:LOCALAPPDATA\Microsoft\OneDrive",
        "$env:APPDATA\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
            $CHANGES_MADE = $true
        }
    }
}

# 8. Prevent Windows Update from reinstalling OneDrive (requires admin)
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
try {
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
    }
    $current = (Get-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue).DisableFileSyncNGSC
    if ($current -ne 1) {
        Set-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -Value 1 -Type DWord
        $CHANGES_MADE = $true
        Write-Host "  OneDrive reinstallation via Windows Update blocked."
    }
} catch {
    Write-Host "  Note: Could not set OneDrive policy (requires admin)."
}

if ($CHANGES_MADE) {
    Write-Host "$PREF_NAME complete. A restart is recommended."
} else {
    Write-Host "$PREF_NAME already configured."
}
