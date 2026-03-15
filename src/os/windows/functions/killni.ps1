# killni - Kill all Node Inspector (--inspect / --debug) processes
#
# Usage:
#   killni

function killni {
    $procs = Get-WmiObject Win32_Process -Filter "Name = 'node.exe'" |
             Where-Object { $_.CommandLine -match '--inspect|--debug' }

    if (-not $procs) {
        Write-Host "No Node Inspector processes found."
        return
    }

    $procs | ForEach-Object {
        Write-Host "Killing Node Inspector process $($_.ProcessId): $($_.CommandLine)"
        Stop-Process -Id $_.ProcessId -Force
    }
}
