---
name: bug-triage
description: "Investigate and reproduce a bug before fixing it. Use when: a bug is reported and you need to locate the root cause, reproduce a failure, understand the blast radius, and plan the minimal fix. Safe to run in read-only mode — no code changes."
argument-hint: "Jira issue key (e.g. PROJ-123), bug description, or error message"
---

# Bug Triage

## When to Use
- A bug report arrives (Jira key, error log, user description)
- You need to understand what is broken before writing any fix
- You want to confirm the bug reproduces before branching

## Goal
Produce a **triage report** with:
1. Reproduction steps (command / test / input)
2. Root cause location (file, function, line range)
3. Blast radius (what else could be affected)
4. Recommended fix strategy (scope and approach, no code yet)

---

## Procedure

### Step 1 — Fetch the bug report from Jira
If a Jira issue key is provided (e.g. `PROJ-123`), read the full ticket using the mcp-atlassian tool:

```
Tool: mcp-atlassian/jira_get_issue
  issue_key: "<PROJ-123>"
```

Extract from the ticket:
- **Summary** — one-line description of the bug
- **Description** — full reproduction steps and context
- **Priority** and **Labels** — guide urgency and scope
- **Acceptance Criteria / Steps to Reproduce** — exact inputs that trigger the bug
- **Linked issues** — related bugs or blocking epics (check `childIssues` if it is an Epic)

If no Jira key is given, collect the same fields manually from the user:
- Error message or stack trace
- Steps to reproduce
- Expected vs actual behavior
- Affected version or commit

### Step 2 — Reproduce locally
Run the failing case to confirm the bug exists in the current code:
```bash
# Run the specific test that fails, if known
go test ./... -run <TestName> -v

# Or run the binary with the triggering input
go run . <args>
```
If no test exists, note it — a new test will be needed during the fix.

### Step 3 — Locate the root cause
Search the codebase for the relevant symbols, error strings, or code paths:
- Use `grep_search` / `semantic_search` to find the relevant code
- Trace the call path from the entry point to the failure
- Read the surrounding context (at least 20 lines before and after)

### Step 4 — Assess blast radius
Check what else calls or depends on the broken code:
```bash
# Find all callers of a function
grep -rn "FunctionName" --include="*.go" .

# Check if there are existing tests for this area
go test ./... -list ".*" 2>&1 | grep -i <pkg>
```

### Step 5 — Write the triage report
Produce a structured summary (keep it concise, under 200 words):

```
## Triage: <short title>

**Reproduction**: `go test ./pkg -run TestXxx`
**Root cause**: `pkg/foo.go:42` — `Bar()` does not handle nil input
**Blast radius**: Only called from `cmd/main.go:17`, low risk
**Fix strategy**: Add nil guard in `Bar()`, add unit test for nil case
**Estimated scope**: 1–2 files, < 20 lines changed
```

---

## Rules
- Do **not** make any code changes during triage
- If reproduction fails, document why and what was tried
- If root cause is unclear after 10 minutes of investigation, escalate with partial findings rather than guessing

## Next Step
Hand the triage report to the **bug-fix** skill (or BugFixer agent) to implement the fix.
