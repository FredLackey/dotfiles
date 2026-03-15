# datauri - Create a base64 data URI from a file
#
# Usage:
#   datauri image.png
#   datauri styles.css

function datauri {
    param(
        [Parameter(Mandatory, Position = 0)][string]$File
    )

    if (-not (Test-Path $File)) {
        Write-Error "File not found: $File"
        return
    }

    $ext = [System.IO.Path]::GetExtension($File).ToLower().TrimStart('.')
    $mimeTypes = @{
        'png'  = 'image/png';  'jpg'  = 'image/jpeg'; 'jpeg' = 'image/jpeg'
        'gif'  = 'image/gif';  'svg'  = 'image/svg+xml'; 'webp' = 'image/webp'
        'txt'  = 'text/plain'; 'html' = 'text/html';  'css'  = 'text/css'
        'js'   = 'application/javascript'; 'json' = 'application/json'
        'pdf'  = 'application/pdf'
    }
    $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { 'application/octet-stream' }

    $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $File).Path)
    $b64   = [Convert]::ToBase64String($bytes)

    if ($mime -like 'text/*') {
        "data:${mime};charset=utf-8;base64,${b64}"
    } else {
        "data:${mime};base64,${b64}"
    }
}
