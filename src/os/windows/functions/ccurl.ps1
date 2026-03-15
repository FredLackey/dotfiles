# ccurl - Fetch a URL and pretty-print the JSON response
#
# Usage:
#   ccurl https://api.example.com/endpoint

function ccurl {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Url
    )

    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 20
}
