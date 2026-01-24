# Starship Integration - Plan Review

## Assessment

The proposed plan is comprehensive and well-aligned with the project's core mandates, particularly the focus on **idempotency** and **simplicity** (avoiding shell frameworks like Oh My Zsh). The step-by-step breakdown is logical and covers all target platforms.

## Strengths

1.  **Strict Idempotency:** The plan explicitly details the Check-Execute-Verify pattern for every installer, which is the most critical rule of this codebase.
2.  **No Framework Dependencies:** Explicitly avoiding Oh My Zsh/Bash reduces complexity and keeps the shell startup fast, which aligns with the performance goals.
3.  **Cross-Platform Parity:** The plan ensures a consistent experience across macOS, Linux, and Windows, which is a key value proposition of these dotfiles.
4.  **Detailed Logic:** The logic for updating `.zshrc`, `.bash_profile`, and `.bashrc` includes safe guards (`if command -v starship...`), ensuring the shell remains functional even if the Starship binary is missing.

## Risks & Areas for Improvement

### 1. Code Duplication (High)
The plan currently dictates creating separate `starship.toml` files for every OS variant (macOS, Ubuntu Desktop, Ubuntu Server, Ubuntu WSL, Windows).
*   **Risk:** These configuration files will inevitably drift apart over time.
*   **Recommendation:** While the plan acknowledges this in Step 11 ("We can refactor to a shared location later"), it is strongly recommended to create a `src/common/files/starship.toml` (or `src/shared/...`) **now** instead of later. All platform-specific installers should copy from this single source of truth.

### 2. Windows Font Installation (Medium)
Step 17 (Windows Nerd Font Installer) notes that `winget` does not support Nerd Fonts and suggests a manual download/script approach.
*   **Risk:** Scripting font installation on Windows is notoriously brittle and often requires specific administrative privileges or COM object manipulation that can be flaky.
*   **Recommendation:** Be prepared for this step to be the most problematic. Consider a fallback that simply opens the download URL for the user if the automated install fails, or strictly relying on `scoop` if `winget` is insufficient (though `scoop` is not currently in the toolset).

### 3. Ubuntu Server Font Installation (Low)
Installing fonts on a headless Ubuntu Server (Step 14) might be unnecessary if it is strictly accessed via SSH (where the client terminal's font renders the prompt).
*   **Recommendation:** The installer should arguably check if it's running in a desktop environment or if the user actually wants server-side fonts (e.g. for VNC). However, installing them doesn't hurt, just consumes disk space.

### 4. Hardcoded Versions
The URL for Nerd Fonts in Step 9 (`.../releases/latest/download/...`) is good for getting the newest, but "latest" can sometimes break if the release asset names change.
*   **Recommendation:** Acceptable for now, but pinning a version (e.g., `v3.1.1`) is safer for long-term stability/idempotency.

## Conclusion

The plan is **APPROVED** for execution, with the strong suggestion to implement the **shared configuration file** immediately to prevent technical debt.
