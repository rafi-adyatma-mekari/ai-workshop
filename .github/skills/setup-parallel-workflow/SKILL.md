---
name: setup-parallel-workflow
description: "Set up parallel development workflow using git worktrees. Use when: starting a bugfix while a feature is in progress, creating an isolated bugfix environment alongside active feature development, managing multiple branches simultaneously in the same repo without stashing or switching branches."
argument-hint: "Optional: branch name or issue number for the bugfix"
---

# Setup Parallel Development Workflow

## When to Use
- You are mid-feature and a bug report arrives that needs immediate attention
- You want to fix a bug without disturbing your current working tree (unstaged changes, build state, open files)
- You need two branches actively checked out at the same time

## Concepts
Git worktrees let you check out a branch into a **separate directory** while keeping your main working tree intact. Both trees share the same `.git` database — no duplication of history or objects.

```
/ai-workshop/             ← main tree (feature branch)
/ai-workshop-bugfix/      ← worktree  (bugfix branch)
```

## Procedure

### 1. Confirm current status
```bash
git status
git branch --show-current
```
Note the current feature branch name. Commit or stash any work you want to preserve before creating the worktree.

### 2. Create the bugfix branch and worktree
```bash
# From the repo root — pick a sibling directory as the worktree path
WORKTREE_PATH="../$(basename "$PWD")-bugfix"
BUGFIX_BRANCH="fix/<issue-or-description>"

git worktree add "$WORKTREE_PATH" -b "$BUGFIX_BRANCH"
```

### 3. Verify worktrees
```bash
git worktree list
```
Expected output shows both paths and their checked-out branches.

### 4. Open the bugfix worktree in a new VS Code window
```bash
code "$WORKTREE_PATH"
```
Use the **BugFixer** agent in that window. Continue using the **FeatureDev** agent in this window.

### 5. After the fix is merged — remove the worktree
```bash
git worktree remove "$WORKTREE_PATH"
git branch -d "$BUGFIX_BRANCH"   # only after PR is merged
```

## Rules
- **Never** create a worktree for a branch that is already checked out elsewhere — git will refuse.
- Keep worktree paths as **siblings** of the main repo directory (not inside it) to avoid `.gitignore` complications.
- The `go.sum` and `go.mod` files are shared via git; run `go mod tidy` independently in each tree if dependencies change.

## References
- [Git worktrees documentation](https://git-scm.com/docs/git-worktree)
- See `bug-triage` skill for the next step after the worktree is set up.
- See `bug-fix` skill for the full fix → test → PR cycle.
