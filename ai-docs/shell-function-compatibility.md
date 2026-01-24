# Shell Function Compatibility: Bash vs Zsh

This document addresses the concern of sourcing shell functions with `#!/bin/bash` shebangs in a zsh environment, and outlines the available options.

## Repository Context

This dotfiles repo supports multiple operating systems and shell environments:

```text
src/os/
├── macos/           # macOS (bash + zsh)
├── ubuntu-desktop/  # Ubuntu Desktop (bash, possibly zsh)
├── ubuntu-server/   # Ubuntu Server (bash)
├── ubuntu-wsl/      # Windows Subsystem for Linux (bash, zsh)
└── windows/         # Windows (PowerShell, cmd, Git Bash)
```

The repo already maintains separate code paths for each platform. Within any platform, having shell-specific function directories is consistent with this architecture - each environment gets optimized code using its native features.

## The Core Issue

**When you source a file, the shebang is completely ignored.**

```bash
# This shebang does NOTHING when the file is sourced
#!/bin/bash

my_function() {
    # This code runs in whatever shell sources it
}
```

When you run `source functions.sh` or `. functions.sh` from zsh, the file's shebang is irrelevant. The code executes in zsh's interpreter, not bash. The shebang only matters when a script is **executed** (e.g., `./script.sh`), not when it's **sourced**.

This means your current `#!/bin/bash` shebangs are essentially decorative comments for sourced function files.

## Compatibility Differences That Matter

### 1. `read -p` (Prompt Option)

**Bash:**
```bash
read -p "Enter name: " name
```

**Zsh:** The `-p` flag means "read from coprocess" - completely different meaning. This will fail with `read: -p: no coprocess`.

**Zsh equivalent:**
```zsh
read "name?Enter name: "
# or POSIX-compliant:
printf "Enter name: "
read name
```

**Your affected function:** `docker-clean.sh` uses `read -p "Are you sure?" -n 1 -r`

### 2. Array Indexing

**Bash:** Arrays are 0-indexed
```bash
arr=(a b c)
echo ${arr[0]}  # prints "a"
```

**Zsh:** Arrays are 1-indexed by default
```zsh
arr=(a b c)
echo ${arr[1]}  # prints "a"
```

**Your current functions:** None appear to use array indexing, so this isn't currently an issue.

### 3. Regex Matching Variables

**Bash:** Uses `$BASH_REMATCH` array
```bash
if [[ "$input" =~ ^([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
fi
```

**Zsh:** Uses `$MATCH` and `$match` array (unless `BASH_REMATCH` option is set)

**Your affected function:** `docker-clean.sh` uses `[[ ! $REPLY =~ ^[Yy]$ ]]` - the regex itself works, but if you needed capture groups, you'd have issues.

### 4. Other Common Bashisms

| Feature               | Bash  | Zsh              | Status in Your Functions |
| --------------------- | ----- | ---------------- | ------------------------ |
| `&> /dev/null`        | Works | Works            | Safe                     |
| `[[ ... ]]`           | Works | Works            | Safe                     |
| `local var`           | Works | Works            | Safe                     |
| `$( ... )`            | Works | Works            | Safe                     |
| `${var:-default}`     | Works | Works            | Safe                     |
| `${!var}` indirect    | Works | Different syntax | Not used                 |
| `mapfile`/`readarray` | Works | Doesn't exist    | Not used                 |

## Your Options

### Option 1: Write POSIX-Compatible Functions

Write functions that work in both bash and zsh by avoiding shell-specific features.

**Pros:**
- Single set of functions
- No maintenance duplication
- Works in bash, zsh, and even sh/dash
- Simpler architecture

**Cons:**
- Must avoid convenient shell-specific features
- Requires testing in multiple shells
- Some operations are more verbose

**Changes needed for your functions:**

```bash
# Instead of:
read -p "Are you sure? (y/N): " -n 1 -r

# Use:
printf "Are you sure? (y/N): "
read -r REPLY
```

For single-character reads without Enter, you'd need:
```bash
# POSIX-ish approach (works in both)
printf "Are you sure? (y/N): "
stty -echo -icanon
REPLY=$(dd bs=1 count=1 2>/dev/null)
stty echo icanon
echo
```

Or simply accept that users press Enter after their choice (simpler, still user-friendly).

### Option 2: Separate Bash and Zsh Directories (Recommended)

Create parallel function directories and source based on current shell.

```text
src/os/macos/functions/
├── bash/
│   ├── ccurl.sh
│   ├── docker-clean.sh
│   └── ...
└── zsh/
    ├── ccurl.sh
    ├── docker-clean.sh
    └── ...
```

In `.bashrc`:
```bash
for f in ~/.dotfiles/src/os/macos/functions/bash/*.sh; do
    source "$f"
done
```

In `.zshrc`:
```zsh
for f in ~/.dotfiles/src/os/macos/functions/zsh/*.sh; do
    source "$f"
done
```

**Pros:**
- Can use each shell's native features optimally
- No compromises on functionality
- Clear separation of concerns
- Consistent with repo architecture (already has separate OS directories)
- Each shell gets idiomatic code (zsh's `read "var?prompt"` vs bash's `read -p`)
- Easier to reason about - no mental overhead of "will this work in both?"

**Cons:**

- Two copies of similar functions per platform
- Must remember to update both when logic changes
- More files to manage

### Option 3: Shell Detection with Conditional Syntax

Use runtime shell detection within functions.

```bash
my_function() {
    if [ -n "$ZSH_VERSION" ]; then
        # zsh-specific code
        read "reply?Enter name: "
    elif [ -n "$BASH_VERSION" ]; then
        # bash-specific code
        read -p "Enter name: " reply
    else
        # POSIX fallback
        printf "Enter name: "
        read reply
    fi
}
```

**Pros:**
- Single file per function
- Can use native features when available
- Graceful fallbacks

**Cons:**
- More complex functions
- Harder to read and maintain
- Must remember to add conditionals for every shell-specific feature

### Option 4: Zsh Compatibility Mode

Zsh has options to improve bash compatibility:

```zsh
# In .zshrc before sourcing functions
setopt BASH_REMATCH      # Use $BASH_REMATCH for regex
setopt KSH_ARRAYS        # 0-indexed arrays
setopt SH_WORD_SPLIT     # Split unquoted parameter expansions
```

**Pros:**
- Minimal changes to existing functions
- Single set of files

**Cons:**
- Doesn't fix everything (e.g., `read -p` still broken)
- Changes zsh behavior globally, may break other things
- Fighting against zsh's natural behavior

### Option 5: Remove Shebangs Entirely

Since shebangs are ignored when sourcing, remove them to avoid confusion. Add a comment indicating compatibility instead.

```bash
# Shell function - compatible with bash and zsh
# Source this file, do not execute directly

my_function() {
    ...
}
```

**Pros:**
- Honest about how the file is used
- No false expectations

**Cons:**
- Doesn't solve compatibility issues, just removes the misleading shebang

## Recommendation

**Option 2 (Separate Directories) is recommended** for this dotfiles repository.

Reasons:

1. **Architectural consistency.** The repo already maintains separate code for macOS, Ubuntu Desktop, Ubuntu Server, Ubuntu WSL, and Windows. Shell-specific directories within each OS follow the same pattern.

2. **No compromises.** Each shell gets idiomatic code. Bash functions use `read -p`, zsh functions use `read "var?prompt"`. No POSIX lowest-common-denominator restrictions.

3. **Cognitive simplicity.** When writing a bash function, think in bash. When writing a zsh function, think in zsh. No mental overhead of compatibility checking.

4. **Future flexibility.** If zsh develops powerful new features, you can use them immediately without worrying about bash compatibility (and vice versa).

5. **The duplication concern is overstated.** Most functions are small utilities. Copying and adapting shell-specific syntax takes minutes, not hours. The logic remains the same - only the shell idioms differ.

### Implementation Steps

1. **Restructure directories:**

   ```text
   src/os/macos/functions/
   ├── bash/
   │   └── *.sh (with #!/bin/bash)
   └── zsh/
       └── *.sh (with #!/bin/zsh)
   ```

2. **Move existing functions to `bash/`** (they're already bash-syntax)

3. **Copy to `zsh/` and adapt:**
   - Change shebang to `#!/bin/zsh`
   - Replace `read -p "prompt" var` with `read "var?prompt"`
   - Adjust any array indexing if needed (1-based in zsh)

4. **Source appropriately** in shell config files:
   - `.bashrc` sources from `functions/bash/`
   - `.zshrc` sources from `functions/zsh/`

## Testing Checklist

When writing new functions:

**For bash functions (`functions/bash/`):**

- [ ] Shebang is `#!/bin/bash`
- [ ] Test by sourcing in bash: `source function.sh && function_name`

**For zsh functions (`functions/zsh/`):**

- [ ] Shebang is `#!/bin/zsh`
- [ ] Replace `read -p "prompt" var` with `read "var?prompt"`
- [ ] Array indexing starts at 1 (if using arrays)
- [ ] Test by sourcing in zsh: `source function.sh && function_name`

**When adapting bash to zsh, watch for:**

| Bash                        | Zsh Equivalent                |
| --------------------------- | ----------------------------- |
| `read -p "prompt" var`      | `read "var?prompt"`           |
| `${arr[0]}` (first element) | `${arr[1]}` (first element)   |
| `${!var}` (indirect)        | `${(P)var}`                   |
| `$BASH_REMATCH`             | `$MATCH` / `$match`           |
| `mapfile` / `readarray`     | `arr=("${(@f)$(command)}")`   |

## References

- [Scripts: bash or zsh – Modern Bash Scripting](https://www.mulle-kybernetik.com/modern-bash-scripting/script-zsh.html)
- [Bash to Zsh Compatibility Guide](https://copicode.com/templates/zsh/bash-to-zsh-compatibility-guide-en.php)
- [Oh My Zsh Shebang Discussion](https://github.com/ohmyzsh/ohmyzsh/issues/5199)
- [Bashism Reference](https://mywiki.wooledge.org/Bashism)
- [Zsh Shell Builtins](https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html)
- [read -p Compatibility Issue](https://github.com/ohmyzsh/ohmyzsh/issues/8330)
