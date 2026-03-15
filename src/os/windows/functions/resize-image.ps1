# resize-image - Resize an image using ImageMagick with high-quality resampling
#
# Usage:
#   resize-image input.jpg output.jpg 800x600
#   resize-image photo.png thumb.png 200x200

function resize-image {
    param(
        [Parameter(Mandatory, Position = 0)][string]$InputFile,
        [Parameter(Mandatory, Position = 1)][string]$OutputFile,
        [Parameter(Mandatory, Position = 2)][string]$Geometry
    )

    if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
        Write-Error "ImageMagick is required but not installed."
        return
    }

    magick $InputFile -filter Sinc -define filter:window=Jinc -resize $Geometry $OutputFile
}
