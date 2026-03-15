# git-backup - Create a timestamped zip backup of a git repository
#
# Usage:
#   git-backup          # Backs up current repo
#   git-backup C:\path  # Backs up repo at path
#
# Backups are saved to ~/git-backups/

function git-backup {
    param(
        [string]$RepoPath = "."
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is required but not installed."
        return
    }

    $resolvedPath = (Resolve-Path $RepoPath).Path
    if (-not (Test-Path (Join-Path $resolvedPath ".git"))) {
        Write-Error "Not a git repository: $resolvedPath"
        return
    }

    $repoName   = Split-Path $resolvedPath -Leaf
    $timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir  = Join-Path $HOME "git-backups"
    $mirrorPath = Join-Path $backupDir "${repoName}-${timestamp}.git"
    $zipPath    = Join-Path $backupDir "${repoName}-${timestamp}.zip"

    # Skip if nothing has changed since last backup
    $lastZip = Get-ChildItem -Path $backupDir -Filter "${repoName}-*.zip" -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($lastZip) {
        $headHash = git -C $resolvedPath rev-parse HEAD 2>$null
        $lastHash = git -C $resolvedPath rev-parse "HEAD@{1}" 2>$null
        if ($headHash -and $headHash -eq $lastHash) {
            Write-Host "No new commits since last backup ($($lastZip.Name)). Skipping."
            return
        }
    }

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }

    Write-Host "Backing up $repoName..."
    git clone --mirror $resolvedPath $mirrorPath 2>&1 | Out-Null

    Write-Host "Compressing to $zipPath..."
    Compress-Archive -Path $mirrorPath -DestinationPath $zipPath -Force
    Remove-Item $mirrorPath -Recurse -Force

    Write-Host "Backup saved: $zipPath"
}
