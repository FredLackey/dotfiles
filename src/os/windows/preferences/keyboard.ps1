$ErrorActionPreference = "Stop"

$PREF_NAME    = "Keyboard Remapping"
$CHANGES_MADE = $false

Write-Host "Configuring $PREF_NAME..."

# Map Caps Lock -> Left Ctrl via the Windows Scancode Map registry value.
# This is exactly what SharpKeys writes - we set it directly so no manual
# UI interaction is needed after setup.
#
# Scancode Map binary format:
#   Bytes  0- 3: header version  (0x00000000)
#   Bytes  4- 7: header flags    (0x00000000)
#   Bytes  8-11: entry count + 1 (0x00000002 = 1 mapping + null terminator)
#   Bytes 12-15: mapping entry   (target: Left Ctrl 0x1D, source: Caps Lock 0x3A)
#   Bytes 16-19: null terminator (0x00000000)
#
# Requires a restart to take effect.

$regPath  = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
$regName  = "Scancode Map"

$desired = [byte[]](
    0x00, 0x00, 0x00, 0x00,   # version
    0x00, 0x00, 0x00, 0x00,   # flags
    0x02, 0x00, 0x00, 0x00,   # 1 mapping + null terminator
    0x1D, 0x00, 0x3A, 0x00,   # Caps Lock (0x3A) -> Left Ctrl (0x1D)
    0x00, 0x00, 0x00, 0x00    # null terminator
)

$current = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName

if ($current -and @(Compare-Object $current $desired).Count -eq 0) {
    Write-Host "$PREF_NAME already configured (Caps Lock -> Left Ctrl)."
} else {
    Set-ItemProperty -Path $regPath -Name $regName -Value $desired -Type Binary
    $CHANGES_MADE = $true
    Write-Host "  Caps Lock remapped to Left Ctrl."
}

if ($CHANGES_MADE) {
    Write-Host "$PREF_NAME applied. A restart is required for the remapping to take effect."
}
