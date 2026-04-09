---
name: bug-fix
description: "Implement a bug fix in an isolated worktree branch, verify with tests, and prepare a pull request. Use when: triage is complete and root cause is known, implementing a fix in the bugfix worktree, adding a regression test, and opening a PR without touching the feature branch."
argument-hint: "Triage report or bug description with root cause"
---

# Bug Fix

## When to Use
- Triage report is ready (root cause identified)
- You are working inside the bugfix worktree (not the feature branch)
- You need to implement, test, and submit the fix

## Prerequisites
- Triage report is available (see `bug-triage` skill)

---

## Procedure

### Step 0 — Create the worktree (ALWAYS first — never fix on the main workspace)
```bash
WORKTREE_PATH="../$(basename "$PWD")-bugfix"
BUGFIX_BRANCH="fix/<issue>"
git worktree add "$WORKTREE_PATH" -b "$BUGFIX_BRANCH"
bash .github/hooks/scripts/copy-env-to-worktree.sh "$WORKTREE_PATH"
```
All subsequent steps run **inside `$WORKTREE_PATH`**, not the main workspace.

### Step 1 — Confirm branch and baseline
```bash
git branch --show-current       # must be fix/<issue>
git worktree list               # confirm you're in the right worktree
go test ./...                   # establish baseline (note pre-existing failures)
```

### Step 2 — Write the regression test first
Before changing production code, add a test that **fails** with the current bug:
```bash
# Run only the new test to confirm it fails
go test ./path/to/pkg -run TestBugReproduction -v
```
This proves the test is meaningful and gives you a passing target.

### Step 3 — Implement the fix
- Make the **minimal** change that fixes the root cause identified in triage
- Do not refactor surrounding code, rename symbols, or fix unrelated issues
- Aim for < 30 lines changed in production code

### Step 4 — Verify
```bash
# Regression test must now pass
go test ./path/to/pkg -run TestBugReproduction -v

# Full test suite must not regress
go test ./...

# Build must succeed
go build ./...
```

### Step 5 — Review the diff
```bash
git diff main...HEAD --stat     # summary of changes
git diff main...HEAD            # full diff for review
```
Confirm:
- Only files related to the fix are modified
- No accidental changes to go.sum / go.mod (unless a dependency was the bug)
- Commit messages are descriptive: `fix: <what was wrong and how it was fixed>`

### Step 6 — Commit and push
```bash
git add -p                      # stage hunks deliberately, not blindly
git commit -m "fix: <concise description>

Fixes #<issue-number>

Root cause: <one-line summary>
Resolution: <one-line summary>"

git push origin fix/<issue>
```

### Step 7 — Open a pull request
Use `gh pr create` to open the PR targeting `main` (**not** the feature branch):

```bash
gh pr create \
  --base main \
  --title "fix: <concise description>" \
  --body "## What
<one paragraph: what was broken and what the fix does>

## Why
<root cause from triage report>

## How to verify
\`\`\`
go test ./path/to/pkg -run TestBugReproduction
\`\`\`
Expected: PASS

Fixes #<issue>"
```

If a Jira issue key is linked, post a comment back to the ticket with `mcp-atlassian/jira_add_comment` containing the PR URL returned by `gh pr create`.

### Step 8 — Return to feature work
After the PR is open, switch back to the main worktree window and continue feature development. The bugfix branch is independent — merging it will not conflict with your feature branch unless they touch the same files.

---

## Rules
- **Never** push the fix to the feature branch
- **Never** merge `main` into the feature branch just to pick up the fix during development — rebase when the PR is merged
- If the fix requires > 3 files changed or > 50 lines, re-triage — scope may be underestimated
- All fixes must have at minimum one test that would have caught the bug

## Cleanup (after PR merges)
```bash
# Run from the main worktree
git worktree remove ../$(basename "$PWD")-bugfix
git fetch origin
git branch -d fix/<issue>
```
