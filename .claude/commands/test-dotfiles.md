# Test Dotfiles Until Clean

Test the dotfiles installation for environment: **$ARGUMENTS**

## Your Task

Execute an iterative test-and-fix cycle until the dotfiles installation passes cleanly for the specified environment.

## Valid Environments

- `ubuntu-server`
- `ubuntu-desktop`
- `ubuntu-wsl`
- `macos`
- `windows`

If `$ARGUMENTS` is empty or not a valid environment, ask the user to specify one.

## Workflow

Repeat the following cycle until the test passes with no errors:

### Step 1: Run Test

Use the **dotfiles-test-runner** agent (via the Task tool with `subagent_type: "dotfiles-test-runner"`) to:
- Test the specified environment in a Docker container
- Produce a results file in `testing/results/`

Prompt the agent with:
```
Test the $ARGUMENTS dotfiles installation in Docker. Create a detailed results file documenting all successes and failures.
```

### Step 2: Check Results

After the test completes:
1. Read the results file produced by the test-runner
2. Check the **Overall Result** field
3. If `PASS`: Congratulations! Report success to the user and stop.
4. If `FAIL`: Continue to Step 3.

### Step 3: Fix Issues

Use the **dotfiles-troubleshooter** agent (via the Task tool with `subagent_type: "dotfiles-troubleshooter"`) to:
- Analyze the results file
- Diagnose root causes
- Fix the issues in the appropriate scripts

Prompt the agent with:
```
Analyze and fix the dotfiles installation failures.
Results file: [path to the results file from Step 1]
Environment: $ARGUMENTS

Diagnose all errors, implement fixes in the appropriate scripts, and document your changes in the results file.
```

### Step 4: Commit and Push

After the troubleshooter makes fixes:
1. Stage the modified files (NOT the results files in `testing/results/`)
2. Commit with a message describing the fixes
3. Push to GitHub

This is required because the test-runner pulls from GitHub to ensure a pristine test.

### Step 5: Loop Back

Return to Step 1 to verify the fixes work. Continue this cycle until the test passes.

## Important Rules

1. **Track iteration count**: Keep count of how many test-fix cycles you've completed. If you exceed 5 iterations without success, stop and report to the user that manual intervention may be needed.

2. **Commit only source changes**: Never commit files in `testing/results/` to git. Only commit actual fixes to scripts in `src/`.

3. **Report progress**: After each iteration, briefly inform the user:
   - Which iteration number this is
   - Whether the test passed or failed
   - If failed, a brief summary of the issues found
   - What fixes were applied (if any)

4. **Preserve results history**: Do not delete previous results files. Each test run creates a new timestamped file, building a history.

5. **Stop on success**: As soon as a test passes, stop the loop and report the good news.

## Example Output

```
Iteration 1: Testing ubuntu-server...
  Result: FAIL
  Issues: 2 errors found (missing curl, permissions on setup.sh)
  Applying fixes...
  Changes committed and pushed.

Iteration 2: Re-testing ubuntu-server...
  Result: FAIL
  Issues: 1 error found (git config failing)
  Applying fixes...
  Changes committed and pushed.

Iteration 3: Re-testing ubuntu-server...
  Result: PASS

All tests passing for ubuntu-server after 3 iterations.
```

## Begin

Start by validating the environment argument, then begin the test-fix cycle.
