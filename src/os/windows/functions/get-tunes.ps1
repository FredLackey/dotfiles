# get-tunes - Download audio and/or video from a URL using yt-dlp
#
# Usage:
#   get-tunes https://...              # Downloads both audio (mp3) and video
#   get-tunes https://... -Mode audio  # Audio only
#   get-tunes https://... -Mode video  # Video only

function get-tunes {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Url,
        [ValidateSet("audio", "video", "both")]
        [string]$Mode = "both"
    )

    if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
        Write-Error "yt-dlp is required but not installed."
        return
    }

    if ($Mode -eq "audio" -or $Mode -eq "both") {
        yt-dlp --extract-audio --audio-format mp3 --output "%(title)s.%(ext)s" $Url
    }
    if ($Mode -eq "video" -or $Mode -eq "both") {
        yt-dlp --format "bestvideo+bestaudio" --output "%(title)s.%(ext)s" $Url
    }
}
