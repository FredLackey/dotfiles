# Shell Functions

This directory contains shell functions organized by shell type.

## Structure

```
functions/
├── bash/
│   ├── main.sh    # Sources all bash functions
│   └── *.sh       # Individual function files
├── zsh/
│   ├── main.sh    # Sources all zsh functions
│   └── *.sh       # Individual function files
└── README.md
```

## Usage

Add the appropriate line to your shell configuration:

**For bash (~/.bashrc):**
```bash
source ~/.dotfiles/src/os/macos/functions/bash/main.sh
```

**For zsh (~/.zshrc):**
```zsh
source ~/.dotfiles/src/os/macos/functions/zsh/main.sh
```

## Adding New Functions

1. Create the function in `bash/` with `#!/bin/bash` shebang
2. Copy to `zsh/` and change shebang to `#!/bin/zsh`
3. Fix any bash-specific syntax (see table below)
4. Add a `source` line to BOTH `bash/main.sh` and `zsh/main.sh`

### Syntax Differences

| Bash                    | Zsh                           |
|-------------------------|-------------------------------|
| `read -p "prompt" var`  | `printf "prompt"; read var`   |
| `read -n 1`             | `read -k 1`                   |
| `${*: -1}`              | `${@[-1]}`                    |
| `${@:1:$#-1}`           | `${@[1,-2]}`                  |
| `${arr[0]}`             | `${arr[1]}`                   |
| `$BASH_REMATCH`         | `$MATCH` / `$match`           |

## Testing

After adding or modifying functions:

1. Open a new terminal with the target shell
2. Verify the function loads: `type function_name`
3. Test the function works as expected
