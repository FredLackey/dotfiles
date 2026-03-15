# docker-clean - Remove ALL Docker containers, images, and volumes
#
# Usage:
#   docker-clean

function docker-clean {
    $confirm = Read-Host "This will remove ALL Docker containers, images, and volumes. Continue? (y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "Aborted."
        return
    }

    Write-Host "Stopping all containers..."
    $containers = docker ps -aq 2>$null
    if ($containers) { docker stop $containers 2>$null | Out-Null }

    Write-Host "Removing all containers..."
    $containers = docker ps -aq 2>$null
    if ($containers) { docker rm $containers 2>$null | Out-Null }

    Write-Host "Removing all images..."
    $images = docker images -q 2>$null
    if ($images) { docker rmi --force $images 2>$null | Out-Null }

    Write-Host "Removing all volumes..."
    $volumes = docker volume ls -q 2>$null
    if ($volumes) { docker volume rm $volumes 2>$null | Out-Null }

    Write-Host "Docker clean complete."
}
