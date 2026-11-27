---
name: deslop
description: Fast diff-only cleanup that removes AI clutter (redundant comments, debug logs, type-silencing casts, unidiomatic guards) from touched lines without changing behavior. Exits immediately when clean. Use for /deslop, "clean up the diff".
argument-hint: "[base branch]"
---

# Deslop

Based on pstack's `deslop` and `no-comments` skills (MIT). Follow `../../references/rules.md` when present.

## 1. Diff-only fast gate
Inspect `git diff <base>...HEAD` plus uncommitted changes (base: `$ARGUMENTS` → runner base branch → repo default branch). Touch **only** added or modified lines.

**Fast exit**: if the diff adds no redundant comments, debug output, type-silencing casts, or unidiomatic guards, stop immediately and return `No slop (0 edits)` — run **no** extra commands.

## 2. Strip clutter on touched lines
- **Comments**: delete comments that repeat code, section banners, commented-out code, and change notes (`// added`, `// fixed`). Keep only license headers, public API docstrings, lint suppressions with reasons, and 1-sentence `why` comments for external constraints.
- **Code**: delete `console.log`/`print`/`debugger`, unused imports/vars, redundant `try/catch` on trusted internal calls, deep nesting flattenable with early returns, and `any`/`as unknown as` casts (replace with real types, or flag if non-trivial).

## 3. Verify & finish
- **Inside `runner`**: commit edits once as `chore: remove leftover comments and debug clutter` (`runner` runs the full check suite immediately after; if checks fail, revert the offending deslop hunk).
- **Standalone by hand**: run typecheck + tests for touched files (undo any behavior-changing edit) and leave changes uncommitted.

Report 1 line: files cleaned and any flagged type suppressions.
