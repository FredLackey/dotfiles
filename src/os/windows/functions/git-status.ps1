# git-status - Show status summary for one or more git repositories
#
# Usage:
#   git-status              # Current repo (or all repos under current dir)
#   git-status C:\path      # Repo at path, or all repos found under path
#   git-status -d           # Only show repos with changes (dirty)
#   git-status -d C:\path   # Dirty repos under path
#   git-status -m 3 C:\path # Limit search depth to 3 levels
#
# Flags:
#   -d        Dirty only — hide clean repos
#   -m N      Max directory depth for repo discovery (default: unlimited)

function git-status {
    param(
        [switch]$d,
        [int]$m = 0,
        [string]$Path = ""
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is required but not installed."
        return
    }

    # Resolve target path
    if (-not $Path) {
        $gitRoot = git rev-parse --show-toplevel 2>$null
        $Path = if ($gitRoot) { $gitRoot } else { Get-Location }
    }
    if (-not (Test-Path $Path)) {
        Write-Error "Path does not exist: $Path"
        return
    }
    $Path = (Resolve-Path $Path).Path

    # Collect repos
    $repos = @()
    if (Test-Path (Join-Path $Path ".git")) {
        $repos = @($Path)
    } else {
        $getChildArgs = @{
            Path    = $Path
            Filter  = ".git"
            Recurse = $true
            Force   = $true
            ErrorAction = "SilentlyContinue"
        }
        $gitDirs = Get-ChildItem @getChildArgs | Where-Object { $_.PSIsContainer }
        if ($m -gt 0) {
            $gitDirs = $gitDirs | Where-Object {
                $rel = $_.FullName.Substring($Path.Length).TrimStart('\').Split('\').Count
                $rel -le ($m + 1)
            }
        }
        $repos = $gitDirs | ForEach-Object { Split-Path $_.FullName -Parent } | Sort-Object
    }

    if ($repos.Count -eq 0) {
        Write-Host "No git repositories found under: $Path"
        return
    }

    $headerPrinted  = $false
    $totalRepos     = $repos.Count
    $cleanRepos     = 0
    $shownRepos     = 0

    foreach ($repo in $repos) {
        # Build relative display path
        $relPath = if ($repo -eq $Path) {
            Split-Path $repo -Leaf
        } else {
            $repo.Substring($Path.Length).TrimStart('\')
        }
        if ($relPath.Length -gt 50) { $relPath = "..." + $relPath.Substring($relPath.Length - 47) }

        # Parse porcelain status
        $unstaged = 0; $staged = 0; $untracked = 0
        $statusOutput = git -C $repo status --porcelain 2>$null
        if ($statusOutput) {
            foreach ($line in ($statusOutput -split "`n")) {
                $line = $line.TrimEnd()
                if (-not $line) { continue }
                $x = $line[0]; $y = if ($line.Length -gt 1) { $line[1] } else { ' ' }
                if ($x -eq '?') { $untracked++ }
                else {
                    if ($x -match '[MADRC]') { $staged++ }
                    if ($y -match '[MADRC]') { $unstaged++ }
                }
            }
        }

        # Get ahead/behind
        $ahead = "-"; $behind = "-"
        $hasUpstream = git -C $repo rev-parse --abbrev-ref "@{u}" 2>$null
        if ($hasUpstream) {
            $ahead  = (git -C $repo rev-list --count "@{u}..HEAD"  2>$null) -replace '\s',''
            $behind = (git -C $repo rev-list --count "HEAD..@{u}"  2>$null) -replace '\s',''
            if (-not $ahead)  { $ahead  = "0" }
            if (-not $behind) { $behind = "0" }
        }

        # Determine color
        $isDirty = $false
        $color   = "Green"
        if ($unstaged -gt 0 -or $staged -gt 0 -or $untracked -gt 0) {
            $color = "Yellow"; $isDirty = $true
        } elseif ($ahead -ne "-" -and [int]$ahead -gt 0) {
            $color = "Cyan"; $isDirty = $true
        } elseif ($behind -ne "-" -and [int]$behind -gt 0) {
            $color = "Magenta"; $isDirty = $true
        } else {
            $cleanRepos++
        }

        if ($d -and -not $isDirty) { continue }

        if (-not $headerPrinted) {
            Write-Host ""
            Write-Host ("  {0,-50}  {1,5}  {2,6}  {3,5}  {4,5}  {5,6}" -f "REPOSITORY","UNSTG","STAGED","UNTRK","AHEAD","BEHIND")
            Write-Host ("  {0,-50}  {1,5}  {2,6}  {3,5}  {4,5}  {5,6}" -f ("─" * 50),("─" * 5),("─" * 6),("─" * 5),("─" * 5),("─" * 6))
            $headerPrinted = $true
        }
        $shownRepos++

        $dUnstaged  = if ($unstaged  -gt 0)                    { "$unstaged"  } else { "." }
        $dStaged    = if ($staged    -gt 0)                    { "$staged"    } else { "." }
        $dUntracked = if ($untracked -gt 0)                    { "$untracked" } else { "." }
        $dAhead     = if ($ahead  -eq "-")                     { "-" } elseif ([int]$ahead  -gt 0) { "$ahead"  } else { "." }
        $dBehind    = if ($behind -eq "-")                     { "-" } elseif ([int]$behind -gt 0) { "$behind" } else { "." }

        Write-Host ("  {0,-50}  {1,5}  {2,6}  {3,5}  {4,5}  {5,6}" -f $relPath,$dUnstaged,$dStaged,$dUntracked,$dAhead,$dBehind) -ForegroundColor $color
    }

    Write-Host ""
    if ($d) {
        Write-Host "  $totalRepos repos scanned, $shownRepos dirty, $cleanRepos clean (hidden)"
    } else {
        Write-Host "  $totalRepos repos scanned, $cleanRepos clean"
    }
    Write-Host "  " -NoNewline
    Write-Host "*" -ForegroundColor Green   -NoNewline; Write-Host " Clean  " -NoNewline
    Write-Host "*" -ForegroundColor Yellow  -NoNewline; Write-Host " Local changes  " -NoNewline
    Write-Host "*" -ForegroundColor Cyan    -NoNewline; Write-Host " Needs push  " -NoNewline
    Write-Host "*" -ForegroundColor Magenta -NoNewline; Write-Host " Needs pull  - No remote"
    Write-Host ""
}
