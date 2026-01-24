# macOS System Preferences Inventory

**Source:** Current system state captured via `defaults read`
**Discovered:** 2026-01-24

This document catalogs all non-default macOS system preferences on the current workstation. These represent the target state for the dotfiles installer scripts to reproduce on a fresh machine.

---

## Table of Contents

1. [Dock](#dock)
2. [Finder](#finder)
3. [Global Domain (System-Wide)](#global-domain-system-wide)
4. [Screenshots](#screenshots)
5. [Trackpad](#trackpad)
6. [Menu Bar Clock](#menu-bar-clock)
7. [TextEdit](#textedit)
8. [Hot Corners](#hot-corners)

---

## Dock

**Domain:** `com.apple.dock`

| Key | Value | Purpose |
|-----|-------|---------|
| `autohide` | `1` | Auto-hide the Dock |
| `autohide-delay` | `0` | No delay before Dock appears on hover |
| `launchanim` | `0` | Disable bouncing animation on app launch |
| `mineffect` | `scale` | Use scale effect when minimizing (instead of genie) |
| `minimize-to-application` | `1` | Minimize windows into their app icon |
| `mru-spaces` | `0` | Don't auto-rearrange Spaces based on most recent use |
| `show-process-indicators` | `1` | Show dots under running apps |
| `show-recents` | `0` | Don't show recent apps section in Dock |
| `showhidden` | `1` | Make hidden app icons translucent |
| `enable-spring-load-actions-on-all-items` | `1` | Enable spring-loading for all Dock items |
| `expose-group-apps` | `0` | Don't group windows by app in Mission Control |
| `persistent-apps` | `()` | No pinned apps (empty Dock) |
| `persistent-others` | `()` | No pinned folders or stacks |

**Apply commands:**
```bash
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
defaults write com.apple.dock expose-group-apps -bool false
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
killall Dock
```

---

## Finder

**Domain:** `com.apple.finder`

| Key | Value | Purpose |
|-----|-------|---------|
| `FXPreferredViewStyle` | `clmv` | Default to column view |
| `ShowPathbar` | `1` | Show path bar at bottom of Finder windows |
| `FXDefaultSearchScope` | `SCcf` | Search the current folder (not entire Mac) |
| `FXEnableExtensionChangeWarning` | `0` | No warning when changing file extensions |
| `NewWindowTarget` | `PfDe` | New Finder windows open to Desktop |
| `NewWindowTargetPath` | `file:///Users/flackey/Desktop/` | Desktop path for new windows |
| `ShowExternalHardDrivesOnDesktop` | `1` | Show external drives on desktop |
| `ShowHardDrivesOnDesktop` | `1` | Show hard drives on desktop |
| `ShowMountedServersOnDesktop` | `1` | Show network volumes on desktop |
| `ShowRemovableMediaOnDesktop` | `1` | Show removable media on desktop |

**Apply commands:**
```bash
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
killall Finder
```

---

## Global Domain (System-Wide)

**Domain:** `NSGlobalDomain`

### Appearance

| Key | Value | Purpose |
|-----|-------|---------|
| `AppleInterfaceStyle` | `Dark` | Dark mode |
| `AppleInterfaceStyleSwitchesAutomatically` | `1` | Auto-switch light/dark based on time of day |
| `AppleShowScrollBars` | `Always` | Always show scrollbars (not just when scrolling) |
| `NSAutomaticWindowAnimationsEnabled` | `0` | Disable window open/close animations |
| `NSUseAnimatedFocusRing` | `0` | Disable animated focus ring |
| `AppleMiniaturizeOnDoubleClick` | `0` | Don't minimize on title bar double-click |

### Keyboard

| Key | Value | Purpose |
|-----|-------|---------|
| `AppleKeyboardUIMode` | `3` | Full keyboard access (tab through all controls) |
| `ApplePressAndHoldEnabled` | `0` | Disable press-and-hold for accent menu (enables key repeat) |
| `KeyRepeat` | `1` | Fastest key repeat rate |
| `InitialKeyRepeat_Level_Saved` | `10` | Short delay before key repeat begins |

### Text Correction (All Disabled)

| Key | Value | Purpose |
|-----|-------|---------|
| `NSAutomaticCapitalizationEnabled` | `0` | Disable auto-capitalization |
| `NSAutomaticDashSubstitutionEnabled` | `0` | Disable smart dashes (-- to em-dash) |
| `NSAutomaticPeriodSubstitutionEnabled` | `0` | Disable double-space to period |
| `NSAutomaticQuoteSubstitutionEnabled` | `0` | Disable smart quotes |
| `NSAutomaticSpellingCorrectionEnabled` | `0` | Disable auto-correct |

### Dialogs

| Key | Value | Purpose |
|-----|-------|---------|
| `NSNavPanelExpandedStateForSaveMode` | `1` | Expand save dialogs by default |
| `NSNavPanelExpandedStateForSaveMode2` | `1` | Expand save dialogs by default (secondary key) |

### Application Behavior

| Key | Value | Purpose |
|-----|-------|---------|
| `NSDisableAutomaticTermination` | `1` | Prevent apps from being auto-terminated when idle |

**Apply commands:**
```bash
# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# Keyboard
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Text Correction
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Application Behavior
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

```

---

## Screenshots

**Domain:** `com.apple.screencapture`

| Key | Value | Purpose |
|-----|-------|---------|
| `disable-shadow` | `1` | No window shadow in window screenshots |
| `location` | `/Users/flackey/Screenshots` | Save screenshots to ~/Screenshots |
| `show-thumbnail` | `0` | No floating thumbnail preview after capture |
| `type` | `png` | Save as PNG format |

**Apply commands:**
```bash
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture show-thumbnail -bool false
defaults write com.apple.screencapture type -string "png"
```

---

## Trackpad

**Domain:** `com.apple.AppleMultitouchTrackpad`

| Key | Value | Purpose |
|-----|-------|---------|
| `Clicking` | `1` | Tap to click enabled |
| `TrackpadRightClick` | `1` | Two-finger tap for right-click |
| `ActuateDetents` | `1` | Haptic feedback on Force Touch |

**Apply commands:**
```bash
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true
```

---

## Menu Bar Clock

**Domain:** `com.apple.menuextra.clock`

| Key | Value | Purpose |
|-----|-------|---------|
| `ShowAMPM` | `1` | Show AM/PM indicator |
| `ShowDate` | `0` | Always show date in menu bar (0=Always, 1=When space allows, 2=Never) |
| `ShowDayOfWeek` | `1` | Show day of week |

**Apply commands:**
```bash
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
killall ControlCenter
```

---

## TextEdit

**Domain:** `com.apple.TextEdit`

| Key | Value | Purpose |
|-----|-------|---------|
| `RichText` | `0` | Default to plain text mode (not rich text) |
| `PlainTextEncoding` | `4` | Use UTF-8 encoding when reading files |
| `PlainTextEncodingForWrite` | `4` | Use UTF-8 encoding when writing files |

**Apply commands:**
```bash
defaults write com.apple.TextEdit RichText -bool false
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
```

---

## Hot Corners

**Domain:** `com.apple.dock`

| Corner | Key | Value | Action |
|--------|-----|-------|--------|
| Top-left | `wvous-tl-corner` | Not set | None (default) |
| Top-right | `wvous-tr-corner` | Not set | None (default) |
| Bottom-left | `wvous-bl-corner` | Not set | None (default) |
| Bottom-right | `wvous-br-corner` | `14` | Quick Note |

**Apply commands:**
```bash
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0
killall Dock
```

---

## Summary

| Category | Settings Count | Restart Required |
|----------|---------------|------------------|
| Dock | 12 | `killall Dock` |
| Finder | 10 | `killall Finder` |
| Global Domain | 16 | Log out / restart |
| Screenshots | 4 | None (immediate) |
| Trackpad | 3 | None (immediate) |
| Menu Bar Clock | 3 | `killall ControlCenter` |
| TextEdit | 3 | None (next launch) |
| Hot Corners | 1 | `killall Dock` |
| **Total** | **52** | |
