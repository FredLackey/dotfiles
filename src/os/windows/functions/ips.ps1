# ips - Scan local network for active IP addresses using nmap
#
# Usage:
#   ips                         # Scan 192.168.1.0/24
#   ips -Subnet 10.0.0.0/24
#   ips -IpOnly                 # Print only IP addresses

function ips {
    param(
        [string]$Subnet  = "192.168.1.0/24",
        [switch]$IpOnly
    )

    if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
        Write-Error "nmap is required but not installed."
        return
    }

    if ($IpOnly) {
        nmap -sn $Subnet | Select-String "Nmap scan report" |
            ForEach-Object { ($_ -replace "Nmap scan report for ", "").ToString().Trim() }
    } else {
        nmap -sn $Subnet
    }
}
