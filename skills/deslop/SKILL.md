---
name: deslop
description: Clean AI clutter from a change without changing its behavior. Removes comments that repeat the code, banners, commented-out code, debug output, unusual defensive checks, type-silencing casts, deep nesting and other patterns that do not match the file, and keeps the few comments that explain why. Run by the runner before review-loop; also by hand on any branch. Use for /deslop, "clean up the diff", "remove AI slop", "too many comments".
argument-hint: "[base branch] (default: the runner's base branch, else the repo's default branch)"
---

# Deslop

Based on pstack's `deslop` and `no-comments` skills (MIT).

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Tidy the change before anyone reviews it. Behavior never changes.

## 1. Scope

The change from the base: `git diff <base>...HEAD` plus uncommitted changes (`git diff`, and new
untracked files). Base: $ARGUMENTS, else the base branch in the runner's settings, else the
repo's default branch. Touch only lines this change added or edited, never older code.

## 2. Comments

**The rule:** a comment stays only where the code cannot explain itself. A comment that stays is
short and easy to understand.

Remove:
- Comments that repeat the code (`// increment the counter`, `// call the API`).
- Banners and section dividers.
- Commented-out code.
- Notes about the change itself (`// new`, `// fixed X`, `// changed to use Y`) and vague TODOs.

Keep, shortened to one plain sentence where possible:
- Why a non-obvious choice was made: an outside constraint (library, platform, API, vendor), or
  a workaround with its issue link.
- License headers.
- Doc comments on a public API.
- A lint or type suppression with a short reason. Without a reason, flag it in the report.

Follow the file: where the file has no comments of a kind, add none.

## 3. Code clutter

Remove when this change added it and it is unusual for the file:
- Debug output (`console.log`, `print`, `debugger`).
- Defensive checks or `try/catch` on trusted internal paths that the rest of the code does not
  guard.
- `any`, `as unknown as` and similar casts that only silence a type error. Use the right type;
  when that needs a bigger change, flag it instead.
- Deep nesting that early returns make flat.
- Unused imports, variables and files.
- Other patterns that differ from the code around them (naming, error handling, style).

## 4. Check

Run typecheck and the tests related to the touched files. A failure means an edit changed
behavior: undo that edit.

- In the runner: commit the result as one commit, `Remove leftover comments and debug code`.
  No edits: no commit.
- By hand: leave the changes uncommitted for the user to review.

## 5. Report

One line: files touched, comments removed, other edits, and flags left for the reviewer.
