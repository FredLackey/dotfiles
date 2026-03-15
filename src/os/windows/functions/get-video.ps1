# get-video - Download a video in MP4 format using yt-dlp
#
# Usage:
#   get-video https://www.youtube.com/watch?v=...

function get-video {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Url
    )

    if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
        Write-Error "yt-dlp is required but not installed."
        return
    }

    yt-dlp --format "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" `
           --output "%(title)s.%(ext)s" `
           $Url
}
