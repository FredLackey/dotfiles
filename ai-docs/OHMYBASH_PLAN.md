# Oh My Bash Migration Plan

This document outlines a step-by-step plan for integrating Oh My Bash into the dotfiles repository while removing redundant functionality. The plan uses a phased approach with testing after each major change.

## Backup Reference

A backup of the original files is available in `/_backup/` for reference during migration.

---

## Documentation Structure

All findings and decisions during migration are tracked in specific sections within this file:

- **Custom Aliases Inventory** → See "Phase 0 Findings: Custom Aliases" section below
- **Custom Exports Inventory** → See "Phase 0 Findings: Custom Exports" section below
- **Custom Options Inventory** → See "Phase 0 Findings: Custom Options" section below
- **Files Created/Modified** → See "File Changes Tracking" section below
- **Oh My Bash Configuration Decisions** → See "Notes and Decisions" section at bottom
- **Migration Timeline** → See "Notes and Decisions" section at bottom
- **Issues/Blockers** → Document in "Migration Issues Log" section below

---

## Phase 0: Preparation and Analysis

**Objective:** Understand current setup and prepare for migration

### Tasks

- [ ] Review current bash configuration files in `src/shell/`
- [ ] Audit `src/shell/bash_aliases` and document findings in "Phase 0 Findings: Custom Aliases" section below
- [ ] Audit `src/shell/bash_exports` and document findings in "Phase 0 Findings: Custom Exports" section below
- [ ] Audit `src/shell/bash_options` and document findings in "Phase 0 Findings: Custom Options" section below
- [ ] Review `src/shell/bash_functions` (note: keeping all ~1726 lines, no audit needed)
- [ ] Identify which Oh My Bash plugins to enable - document in "Plugin Selection" section at bottom
- [ ] Choose Oh My Bash theme - document in "Theme Selection" section at bottom

### Testing Checkpoint

- [ ] No changes made yet - just documentation
- [ ] Ready to proceed to Phase 1

---

## Phase 1: Install Oh My Bash (macOS Only - Test Environment)

**Objective:** Install Oh My Bash on macOS development machine first

### Tasks

- [ ] Create installation script: `src/os/installs/macos/oh-my-bash.sh`
  - [ ] Download Oh My Bash installer
  - [ ] Run installation
  - [ ] Handle existing `~/.bashrc` backup
  - [ ] Set initial theme and plugins
- [ ] Add oh-my-bash.sh to `src/os/installs/macos/main.sh`
- [ ] Run installation on macOS test environment
- [ ] Verify Oh My Bash installed to `~/.oh-my-bash/`
- [ ] Verify `~/.bashrc` now sources Oh My Bash
- [ ] Document any issues in "Phase 1 Issues" section at bottom

### Testing Checkpoint

- [ ] Open new terminal session
- [ ] Verify Oh My Bash theme loads
- [ ] Verify prompt displays correctly
- [ ] Test basic commands: `ls`, `cd`, `git status`
- [ ] Test that custom functions still work (they should, as bash_functions still loaded)
- [ ] **ROLLBACK PLAN:** Restore `~/.bashrc` from backup if issues occur

### Success Criteria

- [ ] Oh My Bash loads without errors
- [ ] Basic shell functionality works
- [ ] Ready to proceed to Phase 2

---

## Phase 2: Configure Oh My Bash Basics

**Objective:** Set up Oh My Bash with optimal plugins and theme

### Tasks

- [ ] Configure `~/.bashrc` Oh My Bash settings:
  - [ ] Set theme: `OSH_THEME="agnoster"` (or chosen theme)
  - [ ] Enable plugins: `plugins=(git docker npm extract bashmarks)`
  - [ ] Set update mode: `DISABLE_AUTO_UPDATE="true"` (manual updates)
- [ ] Create custom directory structure:
  - [ ] Create `~/.oh-my-bash/custom/aliases/`
  - [ ] Create `~/.oh-my-bash/custom/functions/`
  - [ ] Create `~/.oh-my-bash/custom/completions/`
  - [ ] Create `~/.oh-my-bash/custom/themes/` (for theme customization if needed)
- [ ] Document any issues in "Phase 2 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Verify plugins loaded: `echo $plugins`
- [ ] Test git plugin aliases: `g status` (should work as `git status`)
- [ ] Test docker plugin: `dps` (docker ps formatted)
- [ ] Test extract plugin: `extract --help`
- [ ] Verify theme displays git status in prompt

### Success Criteria

- [ ] All plugins load successfully
- [ ] Theme displays correctly with git integration
- [ ] Ready to proceed to Phase 3

---

## Phase 3: Migrate bash_prompt

**Objective:** Replace custom bash_prompt with Oh My Bash theme

### Tasks

- [ ] Compare current `src/shell/bash_prompt` with chosen Oh My Bash theme
- [ ] If needed, create custom theme in `~/.oh-my-bash/custom/themes/custom.theme.sh`
  - [ ] Port Solarized colors if desired
  - [ ] Port custom git status symbols (`+`, `!`, `?`, `$`) if desired
  - [ ] Port terminal title customization if desired
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Comment out or remove `bash_prompt` symlink creation for macOS
  - [ ] Add comment: "# bash_prompt replaced by Oh My Bash theme"
- [ ] Remove `src/shell/macos/bash_prompt` if it exists (OS-specific version)
- [ ] Document any issues in "Phase 3 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Verify new theme/prompt displays correctly
- [ ] Navigate to a git repository
- [ ] Verify git status shows in prompt (branch, uncommitted changes)
- [ ] Test in different scenarios:
  - [ ] Clean repo (no changes)
  - [ ] Repo with staged changes
  - [ ] Repo with unstaged changes
  - [ ] Repo with untracked files
- [ ] Verify prompt is readable and colors work

### Success Criteria

- [ ] Prompt displays correctly with git integration
- [ ] No errors when loading shell
- [ ] Ready to proceed to Phase 4

---

## Phase 4: Migrate bash_autocompletion

**Objective:** Replace custom completion with Oh My Bash completion system

### Tasks

- [ ] Review current `src/shell/bash_autocompletion` content
- [ ] Identify any custom completions not provided by Oh My Bash plugins
- [ ] If custom completions exist, create `~/.oh-my-bash/custom/completions/custom.completion.sh`
  - [ ] Migrate custom `g` alias git completion if needed (may be automatic with git plugin)
  - [ ] Migrate any other custom completions
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Comment out or remove `bash_autocompletion` symlink creation for macOS
  - [ ] Add comment: "# bash_autocompletion replaced by Oh My Bash completion system"
- [ ] Remove `src/shell/macos/bash_autocompletion` if it exists
- [ ] Document any issues in "Phase 4 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Test git completion: `git che<TAB>` (should complete to `checkout`)
- [ ] Test `g` alias completion: `g che<TAB>` (should complete to `checkout`)
- [ ] Test docker completion: `docker ru<TAB>` (should complete to `run`)
- [ ] Test npm completion: `npm in<TAB>` (should complete to `install`)
- [ ] Test path completion: `cd /usr/loc<TAB>` (should complete to `/usr/local/`)

### Success Criteria

- [ ] All completions work as expected
- [ ] Git alias completion works
- [ ] No completion errors
- [ ] Ready to proceed to Phase 5

---

## Phase 5: Migrate bash_aliases (Partial)

**Objective:** Use Oh My Bash plugin aliases and preserve custom aliases

### Tasks

- [ ] Reference the "Phase 0 Findings: Custom Aliases" section for what to keep
- [ ] Create `~/.oh-my-bash/custom/aliases/custom.aliases.sh`:
  - [ ] Add custom aliases from "Custom Aliases to Preserve" section
  - [ ] Do NOT add aliases listed in "Aliases Provided by Oh My Bash Plugins" section
- [ ] Create OS-specific custom alias files if needed:
  - [ ] `~/.oh-my-bash/custom/aliases/macos.aliases.sh` (use "macOS Aliases" from Phase 0 findings)
  - [ ] `~/.oh-my-bash/custom/aliases/ubuntu.aliases.sh` (use "Ubuntu Aliases" from Phase 0 findings)
  - [ ] Source OS-specific file conditionally based on OS detection
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Keep `bash_aliases` symlink for now (contains OS-specific sourcing logic)
  - [ ] OR modify base `bash_aliases` to only source custom Oh My Bash aliases
  - [ ] Add comment about Oh My Bash plugin aliases
- [ ] Document any issues in "Phase 5 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Test Oh My Bash plugin aliases:
  - [ ] `g` (git) - should work
  - [ ] `dps` (docker ps) - check if plugin provides this
  - [ ] Navigation: `..`, `...` - should work
- [ ] Test custom aliases:
  - [ ] `count-files`
  - [ ] `count-folders`
  - [ ] `rm_safe`
  - [ ] Any domain-specific aliases
- [ ] Test OS-specific aliases (macOS):
  - [ ] `hidedesktop` / `showdesktop`
  - [ ] Homebrew shortcuts if any
- [ ] Run `alias` command and verify no conflicts/duplicates

### Success Criteria

- [ ] All aliases work (plugin + custom)
- [ ] No duplicate aliases
- [ ] OS-specific aliases load correctly
- [ ] Ready to proceed to Phase 6

---

## Phase 6: Migrate bash_exports (Partial)

**Objective:** Use Oh My Bash defaults and supplement with custom exports

### Tasks

- [ ] Review Oh My Bash default exports (check `~/.oh-my-bash/lib/`) and document in "Phase 0 Findings: Custom Exports" section if not already done
- [ ] Reference the "Phase 0 Findings: Custom Exports" section for what to preserve
- [ ] Create `~/.oh-my-bash/custom/exports.sh`:
  - [ ] Add exports from "Custom Exports to Preserve" section
  - [ ] Do NOT add exports listed in "Exports Provided by Oh My Bash" section
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Comment out or remove `bash_exports` symlink creation for macOS
  - [ ] Add comment: "# bash_exports replaced by Oh My Bash defaults + custom/exports.sh"
- [ ] Document any issues in "Phase 6 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Verify history settings: `echo $HISTSIZE` (should be appropriate value)
- [ ] Test man page colors: `man ls` (should have colors)
- [ ] Test custom environment variables:
  - [ ] `echo $NODE_REPL_HISTORY_SIZE`
  - [ ] `echo $PYTHONIOENCODING`
  - [ ] `echo $EDITOR`
- [ ] Verify locale settings: `locale`
- [ ] Run `env | grep -i hist` to verify history configuration

### Success Criteria

- [ ] All required environment variables are set
- [ ] Man pages display with colors
- [ ] History configuration works as expected
- [ ] Ready to proceed to Phase 7

---

## Phase 7: Migrate bash_options (Partial)

**Objective:** Use Oh My Bash defaults and supplement with custom options

### Tasks

- [ ] Review Oh My Bash default shell options (check `~/.oh-my-bash/lib/`) and document in "Phase 0 Findings: Custom Options" section if not already done
- [ ] Reference the "Phase 0 Findings: Custom Options" section for what to preserve
- [ ] Create `~/.oh-my-bash/custom/options.sh`:
  - [ ] Add options from "Custom Options to Preserve" section
  - [ ] Do NOT add options listed in "Options Provided by Oh My Bash" section
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Comment out or remove `bash_options` symlink creation for macOS
  - [ ] Add comment: "# bash_options replaced by Oh My Bash defaults + custom/options.sh"
- [ ] Document any issues in "Phase 7 Issues" section at bottom

### Testing Checkpoint

- [ ] Reload shell: `exec bash`
- [ ] Test vi mode if enabled: Press `ESC` then `k` (should navigate history)
- [ ] Test shell options:
  - [ ] `shopt | grep autocd` (verify setting)
  - [ ] `shopt | grep cdspell` (verify setting)
  - [ ] `shopt | grep histappend` (verify setting)
  - [ ] Test autocd: type `Documents` instead of `cd Documents` (should work)
  - [ ] Test cdspell: `cd /usrr/local` (should correct to `/usr/local`)

### Success Criteria

- [ ] All desired shell options are active
- [ ] Vi mode works if enabled
- [ ] Shell behavior matches expectations
- [ ] Ready to proceed to Phase 8

---

## Phase 8: Update Symlink Creation and Installation Scripts

**Objective:** Update scripts to support Oh My Bash for macOS

### Tasks

- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Add logic to detect if Oh My Bash is installed
  - [ ] Skip symlinking bash_prompt, bash_autocompletion, bash_exports, bash_options for macOS if Oh My Bash exists
  - [ ] Keep symlinking bash_functions (preserve custom functions)
  - [ ] Keep symlinking bash_aliases initially (may contain OS-specific logic)
  - [ ] Add comments explaining Oh My Bash integration
- [ ] Verify oh-my-bash.sh installation script in `src/os/installs/macos/`
- [ ] Update `src/os/installs/macos/main.sh`:
  - [ ] Ensure oh-my-bash.sh is called in appropriate order
  - [ ] Should run early, before bash config symlinking
- [ ] Create `~/.oh-my-bash/custom/functions/dotfiles.functions.sh`:
  - [ ] Source main bash_functions: `source "$HOME/.bash_functions_main"`
  - [ ] This ensures custom functions still load via Oh My Bash
- [ ] Document any issues in "Phase 8 Issues" section at bottom

### Testing Checkpoint

- [ ] Run symbolic link creation: `./src/os/create_symbolic_links.sh` (on test VM)
- [ ] Verify symlinks created:
  - [ ] `ls -la ~ | grep bash` (check what's symlinked)
  - [ ] `bash_functions` should be symlinked
  - [ ] `bash_prompt`, `bash_exports`, etc. should NOT be symlinked (for macOS)
- [ ] Open new terminal session
- [ ] Verify everything still works:
  - [ ] Oh My Bash theme loads
  - [ ] Custom functions work
  - [ ] Custom aliases work
  - [ ] Completions work

### Success Criteria

- [ ] Symlink script handles Oh My Bash correctly
- [ ] All functionality preserved
- [ ] Clean separation between Oh My Bash and custom dotfiles
- [ ] Ready to proceed to Phase 9

---

## Phase 9: Extend to Other OS Variants (Ubuntu, Raspberry Pi)

**Objective:** Install Oh My Bash on other supported operating systems

### Tasks

- [ ] Create `src/os/installs/ubuntu-{version}-{type}/oh-my-bash.sh` for each Ubuntu variant:
  - [ ] ubuntu-20-svr
  - [ ] ubuntu-22-svr
  - [ ] ubuntu-23-svr
  - [ ] ubuntu-24-svr
  - [ ] ubuntu-24-wks
- [ ] Create `src/os/installs/raspberry-pi-os/oh-my-bash.sh`
- [ ] Update each OS's `main.sh` to call oh-my-bash.sh
- [ ] Update `src/os/create_symbolic_links.sh`:
  - [ ] Add Oh My Bash detection for all OS variants
  - [ ] Skip appropriate files for each OS when Oh My Bash installed
- [ ] Create OS-specific custom aliases if needed:
  - [ ] Ubuntu-specific APT aliases
  - [ ] Raspberry Pi-specific aliases
- [ ] Document any issues in "Phase 9 Issues" section at bottom

### Testing Checkpoint (Per OS)

For each OS variant:
- [ ] Spin up test VM with target OS
- [ ] Run setup script: `./src/os/setup.sh -y`
- [ ] Verify Oh My Bash installs successfully
- [ ] Open new terminal session
- [ ] Test prompt, completions, aliases, functions
- [ ] Document any OS-specific issues

### Success Criteria

- [ ] Oh My Bash works on all supported OS variants
- [ ] Each OS has appropriate custom configurations
- [ ] No regression in functionality
- [ ] Ready to proceed to Phase 10

---

## Phase 10: Clean Up Base Shell Files (Optional)

**Objective:** Remove or archive replaced shell configuration files

### Tasks

- [ ] Decision point: Keep or remove replaced files from `src/shell/`?
  - Option A: Keep for reference (add README explaining Oh My Bash replacement)
  - Option B: Move to `src/shell/_archived/` directory
  - Option C: Delete entirely (rely on git history and /_backup/)
- [ ] If keeping files, add `src/shell/README.md`:
  - [ ] Explain Oh My Bash integration
  - [ ] Document which files are still used
  - [ ] Document which files are replaced by Oh My Bash
- [ ] Update main repository README.md:
  - [ ] Add section on Oh My Bash integration
  - [ ] Update setup instructions
  - [ ] Document custom Oh My Bash configurations
- [ ] Clean up OS-specific shell directories:
  - [ ] Remove replaced files from `src/shell/macos/`
  - [ ] Remove replaced files from `src/shell/ubuntu-*/`
  - [ ] Keep bash_functions and any true OS-specific customizations
- [ ] Document any issues in "Phase 10 Issues" section at bottom

### Testing Checkpoint

- [ ] Run linting: `./scripts/lint/shell.sh`
- [ ] Run markdown linting: `./scripts/lint/markdown.sh`
- [ ] Verify no broken links: `./scripts/check_links/markdown.sh`
- [ ] Test full setup on fresh VM (one OS variant)
- [ ] Verify all documentation is accurate

### Success Criteria

- [ ] Repository is clean and well-documented
- [ ] All linting passes
- [ ] Setup works on fresh installation
- [ ] Ready to proceed to Phase 11

---

## Phase 11: Final Testing and Documentation

**Objective:** Comprehensive testing and final documentation

### Tasks

- [ ] Test complete setup flow on fresh VMs:
  - [ ] macOS (if available via CI/CD)
  - [ ] Ubuntu 24.04 Server
  - [ ] Ubuntu 24.04 Workstation
  - [ ] Raspberry Pi OS (if available)
- [ ] Document Oh My Bash integration in main README.md:
  - [ ] Add "Oh My Bash Integration" section
  - [ ] List which Oh My Bash plugins are used
  - [ ] Explain custom configuration location (`~/.oh-my-bash/custom/`)
  - [ ] Document theme selection
- [ ] Update CLAUDE.md:
  - [ ] Add Oh My Bash information to architecture section
  - [ ] Update shell configuration documentation
  - [ ] Note which files are replaced vs preserved
- [ ] Create migration guide for existing users:
  - [ ] Document steps for users upgrading existing installations
  - [ ] Provide rollback instructions
  - [ ] List potential breaking changes
- [ ] Test GitHub Actions CI/CD:
  - [ ] Ensure workflows still pass with Oh My Bash changes
  - [ ] Update CI/CD scripts if needed
- [ ] Document any issues in "Phase 11 Issues" section at bottom

### Testing Checkpoint

- [ ] All tests pass on all supported platforms
- [ ] Documentation is complete and accurate
- [ ] CI/CD pipeline succeeds
- [ ] No regressions in functionality

### Success Criteria

- [ ] Complete Oh My Bash integration across all supported OS variants
- [ ] All functionality preserved or improved
- [ ] Comprehensive documentation
- [ ] Migration complete

---

## Rollback Plan (Emergency)

If critical issues occur at any phase:

1. **Immediate Rollback:**
   ```bash
   # Restore original dotfiles from backup
   cp -r /_backup/src/shell/* src/shell/
   cp -r /_backup/src/os/* src/os/

   # Recreate symlinks with original files
   ./src/os/create_symbolic_links.sh

   # Reload shell
   exec bash
   ```

2. **Uninstall Oh My Bash:**
   ```bash
   # Remove Oh My Bash
   rm -rf ~/.oh-my-bash

   # Restore original .bashrc if backed up
   mv ~/.bashrc.pre-oh-my-bash ~/.bashrc

   # Reload shell
   exec bash
   ```

3. **Restore from git:**
   ```bash
   git checkout main
   git pull
   ./src/os/create_symbolic_links.sh
   exec bash
   ```

---

## Phase 0 Findings: Custom Aliases

**Location:** Document findings from `src/shell/bash_aliases` and OS-specific variants

### Aliases Provided by Oh My Bash Plugins
*(Document which aliases we can remove because Oh My Bash plugins provide them)*

**From base bash_aliases (src/shell/bash_aliases):**
- `..`, `...`, `....` - Navigation shortcuts (provided by Oh My Bash `common` plugin)
- `g="git"` - Git shortcut (provided by Oh My Bash `git` plugin)
- `n="npm"` - NPM shortcut (provided by Oh My Bash `npm` plugin if available)
- `y="yarn"` - Yarn shortcut (may be in Oh My Bash plugins)
- Possibly `ll="ls -l"` (common in Oh My Bash)

**Note:** These can potentially be removed from our custom config if Oh My Bash plugins provide them.

### Custom Aliases to Preserve
*(Document which aliases are unique and must be kept)*

**From base bash_aliases (src/shell/bash_aliases:26-56):**
- `:q="exit"` - Vim-style exit
- `c="clear"` - Clear shortcut
- `cd..="cd .."` - Typo correction
- `ch="history -c && > ~/.bash_history"` - Clear history
- `cp="cp -iv"` - Interactive/verbose copy
- `d="cd ~/Desktop"` - Desktop shortcut
- `e="vim --"` - Vim editor shortcut
- `ip="dig +short myip.opendns.com @resolver1.opendns.com"` - External IP
- `m="man"` - Man page shortcut
- `map="xargs -n1"` - Map function
- `mkdir="mkdir -pv"` - Recursive/verbose mkdir
- `mv="mv -iv"` - Interactive/verbose move
- `p="cd ~/projects"` - Projects shortcut
- `path='printf "%b\n" "${PATH//:/\\n}"'` - Display PATH
- `q="exit"` - Exit shortcut
- `rm="rm -rf --"` - Dangerous but configured (overridden by rm_safe below)
- `t="tmux"` - Tmux shortcut
- `count-files` - Count files in current directory
- `count-folders` - Count folders in current directory
- `count` - Count both files and folders
- `rm='rm_safe'` - Safe rm wrapper (calls bash_functions:rm_safe)

### OS-Specific Aliases
*(Document aliases specific to macOS, Ubuntu, Raspberry Pi)*

#### macOS Aliases
**From src/shell/macos/bash_aliases:**
- `afk="osascript -e 'tell application \"System Events\" to sleep'"` - Lock screen
- `brewd`, `brewi`, `brewr`, `brews`, `brewu` - Homebrew shortcuts
- `clear-dns-cache` - Clear macOS DNS cache
- `empty-trash` - Empty macOS trash
- `hide-desktop-icons`, `show-desktop-icons` - Toggle desktop icons
- `hide-hidden-files`, `show-hidden-files` - Toggle hidden files in Finder
- `o="open"` - Open files/folders
- `u` - System + Homebrew updates
- `iso` - ISO date format (TZ=America/Los_Angeles)
- `local-ip="ipconfig getifaddr en1"` - Get local IP
- `ports="lsof -i -P -n"` - Show network ports
- `code-all` - Open all subdirectories in VS Code
- `packages` - Find package.json files with modification times

#### Ubuntu Aliases
**From src/shell/ubuntu-24-wks/bash_aliases and ubuntu-24-svr/bash_aliases:**
- `afk="gnome-screensaver-command --lock"` - Lock screen (different from macOS)
- `apti`, `aptr`, `apts`, `aptu` - APT package manager shortcuts
- `empty-trash="rm -rf ~/.local/share/Trash/files/*"` - Empty trash (different from macOS)
- `u` - System updates via APT (different from macOS)
- `local-ip='hostname -I | awk '{print $1}''` - Get local IP (different from macOS)
- `packages` - Find package.json (different stat syntax than macOS)
- Commented out: `hide/show-desktop-icons`, `o` (xdg-open)

**Note:** count-files, count-folders, count, rm_safe appear in both base and Ubuntu files (duplicates)

#### Raspberry Pi Aliases
**Similar to Ubuntu aliases** - Need to verify src/shell/raspberry-pi-os/bash_aliases

---

## Phase 0 Findings: Custom Exports

**Location:** Document findings from `src/shell/bash_exports`

### Exports Provided by Oh My Bash
*(Document which exports Oh My Bash already sets)*

**Need to verify after Oh My Bash installation, but commonly provided:**
- `HISTCONTROL` - Oh My Bash likely sets this
- `HISTFILESIZE` - Oh My Bash likely sets this (may differ from our 10000)
- `HISTSIZE` - Oh My Bash likely sets this (may differ from our 10000)
- `HISTIGNORE` - May or may not be set by Oh My Bash
- `EDITOR` - Commonly set by Oh My Bash or left to user

**Action:** After Phase 1, check `~/.oh-my-bash/lib/*.sh` to confirm what's set.

### Custom Exports to Preserve
*(Document which exports we need to keep in `~/.oh-my-bash/custom/exports.sh`)*

**From src/shell/bash_exports - Must preserve:**
- `BASH_SILENCE_DEPRECATION_WARNING=1` (macOS specific - line 13)
- `EDITOR="vim"` (if not set by Oh My Bash - line 19)
- `HISTCONTROL=ignoreboth` (if Oh My Bash differs - line 25)
- `HISTFILESIZE=10000` (if Oh My Bash default differs - line 32)
- `HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"` (custom pattern - line 38)
- `HISTSIZE=10000` (if Oh My Bash default differs - line 45)
- `LANG="en_US"` (locale setting - line 51)
- `LC_ALL="en_US.UTF-8"` (locale setting - line 52)
- `LESS_TERMCAP_md` - Man page color (bold green) - line 58
- `LESS_TERMCAP_me` - Man page color (reset) - line 59
- `MANPAGER="less -X"` - Don't clear screen after man - line 65
- `NODE_REPL_HISTORY_SIZE=10000` - Node REPL history - line 74
- `PROMPT_COMMAND` customization (history -a, update_terminal_cwd cleanup) - lines 81-101
- `PYTHONIOENCODING="UTF-8"` - Python encoding - line 107
- `twilio autocomplete:script bash` - Twilio CLI - line 111

**Decision needed:**
- PROMPT_COMMAND handling may conflict with Oh My Bash. May need to integrate carefully.
- Some exports may be better in OS-specific custom files (BASH_SILENCE_DEPRECATION_WARNING)

---

## Phase 0 Findings: Custom Options

**Location:** Document findings from `src/shell/bash_options`

### Options Provided by Oh My Bash
*(Document which shell options Oh My Bash already sets)*

**Need to verify after Oh My Bash installation, but commonly set by Oh My Bash:**
- `shopt -s checkwinsize` - Update LINES/COLUMNS (very common)
- `shopt -s cmdhist` - Multi-line command history (common)
- `shopt -s histappend` - Append to history (very common)
- Possibly: `dotglob`, `extglob`, `no_empty_cmd_completion`

**Action:** After Phase 1, check `~/.oh-my-bash/lib/*.sh` to confirm which are set.

### Custom Options to Preserve
*(Document which options we need to keep in `~/.oh-my-bash/custom/options.sh`)*

**From src/shell/bash_options - Must preserve:**
- `set -o vi` - **CRITICAL** - Vi editing mode (user preference, line 11)
- `shopt -s autocd` - Auto-prepend cd (line 17)
- `shopt -s cdspell` - Autocorrect cd typos (line 23)
- `shopt -s checkwinsize` - Update LINES/COLUMNS (line 30) - if not in Oh My Bash
- `shopt -s cmdhist` - Multi-line command history (line 36) - if not in Oh My Bash
- `shopt -s dotglob` - Include .* in glob (line 42) - if not in Oh My Bash
- `shopt -s extglob` - Extended pattern matching (line 48) - if not in Oh My Bash
- `shopt -s histappend` - Append to history (line 54) - if not in Oh My Bash
- `shopt -s no_empty_cmd_completion` - Don't complete on empty line (line 61)
- `shopt -s nocaseglob` - Case-insensitive filename expansion (line 68)

**Strategy:**
- Definitely include `set -o vi` in custom/options.sh
- For shopt settings: Only include those NOT set by Oh My Bash (verify in Phase 1)
- If Oh My Bash sets them, we can skip duplicating

---

## Migration Issues Log

**Purpose:** Track any issues, blockers, or unexpected findings during migration

### Phase 1 Issues
-

### Phase 2 Issues
-

### Phase 3 Issues
-

### Phase 4 Issues
-

### Phase 5 Issues
-

### Phase 6 Issues
-

### Phase 7 Issues
-

### Phase 8 Issues
-

### Phase 9 Issues
-

### Phase 10 Issues
-

### Phase 11 Issues
-

---

## File Changes Tracking

**Purpose:** Track all files created, modified, or deleted during migration

### Repository Files Created
*(Files added to the dotfiles repository)*

- [ ] `src/os/installs/macos/oh-my-bash.sh` (Phase 1)
- [ ] `src/os/installs/ubuntu-20-svr/oh-my-bash.sh` (Phase 9)
- [ ] `src/os/installs/ubuntu-22-svr/oh-my-bash.sh` (Phase 9)
- [ ] `src/os/installs/ubuntu-23-svr/oh-my-bash.sh` (Phase 9)
- [ ] `src/os/installs/ubuntu-24-svr/oh-my-bash.sh` (Phase 9)
- [ ] `src/os/installs/ubuntu-24-wks/oh-my-bash.sh` (Phase 9)
- [ ] `src/os/installs/raspberry-pi-os/oh-my-bash.sh` (Phase 9)
- [ ] Other: ________________

### Repository Files Modified
*(Files changed in the dotfiles repository)*

- [ ] `src/os/installs/macos/main.sh` (Phase 1)
- [ ] `src/os/create_symbolic_links.sh` (Phases 3-8)
- [ ] `src/os/installs/ubuntu-*/main.sh` (Phase 9)
- [ ] `src/os/installs/raspberry-pi-os/main.sh` (Phase 9)
- [ ] `README.md` (Phase 10)
- [ ] `CLAUDE.md` (Phase 11)
- [ ] Other: ________________

### Repository Files Deleted/Archived
*(Files removed from the dotfiles repository)*

- [ ] `src/shell/macos/bash_prompt` (Phase 3)
- [ ] `src/shell/macos/bash_autocompletion` (Phase 4)
- [ ] `src/shell/macos/bash_exports` (Phase 6)
- [ ] `src/shell/macos/bash_options` (Phase 7)
- [ ] `src/shell/bash_prompt` (Phase 10 - decision pending)
- [ ] `src/shell/bash_autocompletion` (Phase 10 - decision pending)
- [ ] `src/shell/bash_exports` (Phase 10 - decision pending)
- [ ] `src/shell/bash_options` (Phase 10 - decision pending)
- [ ] Other: ________________

### User Home Directory Files Created
*(Files created in `~/.oh-my-bash/custom/` - NOT in repository)*

- [ ] `~/.oh-my-bash/custom/aliases/custom.aliases.sh` (Phase 5)
- [ ] `~/.oh-my-bash/custom/aliases/macos.aliases.sh` (Phase 5)
- [ ] `~/.oh-my-bash/custom/aliases/ubuntu.aliases.sh` (Phase 5)
- [ ] `~/.oh-my-bash/custom/exports.sh` (Phase 6)
- [ ] `~/.oh-my-bash/custom/options.sh` (Phase 7)
- [ ] `~/.oh-my-bash/custom/functions/dotfiles.functions.sh` (Phase 8)
- [ ] `~/.oh-my-bash/custom/themes/custom.theme.sh` (Phase 3 - if needed)
- [ ] `~/.oh-my-bash/custom/completions/custom.completion.sh` (Phase 4 - if needed)
- [ ] Other: ________________

### User Home Directory Files Modified
*(Files modified in user home directory)*

- [ ] `~/.bashrc` (Phase 1 - Oh My Bash installer modifies this)
- [ ] `~/.bashrc` (Phase 2 - manual configuration)
- [ ] Other: ________________

---

## Notes and Decisions

### Theme Selection
- [x] Chosen theme: **`powerline-multiline`** (alternative: `agnoster` or `brainy`)
- [x] Reason:
  - Provides git status indicators similar to current prompt
  - Multi-line format matches current username@hostname: /path structure
  - Widely used and well-maintained
  - Supports Solarized-like colors
- [ ] Customizations needed:
  - After Phase 2, evaluate if git status symbols match current (+, !, ?, $)
  - May need to create custom theme if exact Solarized colors are required
  - Terminal title customization may need to be added separately

### Plugin Selection
- [x] git - **Yes** - Reason: Provides `g` alias and git completions (replaces our manual git alias)
- [x] docker - **Yes** - Reason: Provides docker completions and potentially docker ps shortcuts
- [x] npm - **Yes** - Reason: Provides `n` alias and npm completions (replaces our manual npm alias)
- [x] extract - **Yes** - Reason: Useful utility for extracting archives (tar, zip, etc.)
- [ ] bashmarks - **Maybe** - Reason: Provides directory bookmarks, evaluate if useful in Phase 2
- [ ] ansible - **No** - Not currently using Ansible
- [ ] aws - **No** - Not currently using AWS CLI
- [ ] python - **Maybe** - If working with Python projects, provides useful aliases
- [x] Other: **`common`** - Provides navigation aliases (.., ..., etc.) used in base bash_aliases

### Custom Files Preserved
- [x] bash_functions (all ~1726 lines) - **KEEP EVERYTHING** - No Oh My Bash equivalent
- [x] Custom aliases: See "Phase 0 Findings: Custom Aliases" - Approx. 20+ custom aliases preserved
- [x] Custom exports: See "Phase 0 Findings: Custom Exports" - 15+ custom exports preserved (man colors, Node/Python settings, etc.)
- [x] Custom options: See "Phase 0 Findings: Custom Options" - Vi mode + 9 shopt settings (subset after verifying Oh My Bash defaults)

### Migration Timeline
- Start Date: **2025-10-20** (Phase 0 complete)
- Phase 1 Complete: ________________
- Phase 2 Complete: ________________
- Phase 3 Complete: ________________
- Phase 4 Complete: ________________
- Phase 5 Complete: ________________
- Phase 6 Complete: ________________
- Phase 7 Complete: ________________
- Phase 8 Complete: ________________
- Phase 9 Complete: ________________
- Phase 10 Complete: ________________
- Phase 11 Complete: ________________
- Migration Complete: ________________

---

## Open Questions

- [ ] Should server variants use Oh My Bash? (Adds overhead vs benefits)
  - **Recommendation:** Yes, install on servers too. Benefits:
    - Consistent shell experience across all environments
    - Completion and plugins improve productivity even on servers
    - Minimal overhead with proper plugin selection (skip heavy themes on servers)
  - **Server-specific consideration:** Use simpler theme (e.g., `minimal`) instead of powerline

- [x] Keep vi mode or use default emacs mode?
  - **Decision: KEEP VI MODE** - Already configured in bash_options (set -o vi)
  - Will be preserved in `~/.oh-my-bash/custom/options.sh`

- [ ] Archive old shell files or delete entirely?
  - **Recommendation:** Option B - Move to `src/shell/_archived/` directory
  - Reasoning:
    - Keeps them accessible without cluttering main directory
    - Better than relying only on git history
    - Easier to reference if needed
  - **Decision in Phase 10**

- [x] Custom theme vs existing Oh My Bash theme?
  - **Decision: Start with existing theme** (`powerline-multiline`)
  - Evaluate in Phase 3 if customization needed
  - Only create custom theme if essential features missing

- [ ] Impact on shell startup time?
  - **Action:** Benchmark in Phase 2 with `time bash -i -c exit`
  - Compare before/after Oh My Bash installation
  - If too slow, reduce plugins or use lighter theme
  - **Acceptable threshold:** < 500ms for interactive startup

---

## Post-Migration Tasks

- [ ] Monitor shell startup performance
- [ ] Gather feedback from multi-OS usage
- [ ] Document any Oh My Bash customizations made
- [ ] Consider contributing useful customizations back to Oh My Bash community
- [ ] Update forking documentation with Oh My Bash considerations
