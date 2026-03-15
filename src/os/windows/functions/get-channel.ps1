# get-channel - Download all videos from a YouTube channel using yt-dlp
#
# Usage:
#   get-channel https://www.youtube.com/@channelname

function get-channel {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Url
    )

    if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
        Write-Error "yt-dlp is required but not installed."
        return
    }

    yt-dlp --output "%(upload_date)s - %(title)s.%(ext)s" $Url
}
