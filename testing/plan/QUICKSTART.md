# Docker Testing Quick Start

## First Time Setup

```bash
# 1. Make sure Docker is running
docker info

# 2. Build the test images (only needed once)
./testing/scripts/build.sh
```

## Daily Testing Workflow

```bash
# Test a single environment
./testing/scripts/test.sh ubuntu-server

# Test all environments
./testing/scripts/test-all.sh
```

## Development Workflow (Fix → Test → Repeat)

```bash
# 1. Test with local files (no need to push to GitHub)
./testing/scripts/test.sh ubuntu-server --local

# 2. If test fails:
#    - Read the error message
#    - Fix the script
#    - Run test again (container is fresh each time)

# 3. Once local tests pass, push to GitHub

# 4. Test remote install to verify GitHub works
./testing/scripts/test.sh ubuntu-server --branch your-branch-name
```

## Interactive Debugging

```bash
# Get a shell inside a fresh container
./testing/scripts/test.sh ubuntu-server --interactive

# Inside the container, manually run:
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"

# Or test local files:
~/.dotfiles/src/setup.sh

# Type 'exit' when done
```

## Cleanup

```bash
# Remove containers only
./testing/scripts/clean.sh

# Remove containers AND images
./testing/scripts/clean.sh --all
```

## Command Reference

| Command | What it does |
|---------|--------------|
| `./testing/scripts/build.sh` | Build Docker images |
| `./testing/scripts/test.sh ubuntu-server` | Test Ubuntu Server |
| `./testing/scripts/test.sh ubuntu-desktop` | Test Ubuntu Desktop |
| `./testing/scripts/test.sh ubuntu-wsl` | Test Ubuntu WSL |
| `./testing/scripts/test-all.sh` | Test all environments |
| `./testing/scripts/clean.sh` | Remove containers |
| `./testing/scripts/clean.sh --all` | Remove containers + images |

## Options

| Option | Description |
|--------|-------------|
| `--local` | Use local files instead of GitHub |
| `--interactive` | Get a shell for manual testing |
| `--branch <name>` | Test specific GitHub branch |
| `--stop-on-fail` | Stop after first failure (test-all.sh) |
