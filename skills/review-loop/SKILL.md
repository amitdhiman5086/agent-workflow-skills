---
name: review-loop
description: Review an agent's change in a fresh, separate session before the PR opens, judge which checks matter (Done when, scope, bugs, project rules, leftovers, and the UI in a real browser when the change is visual), send every finding back to the coder, and stop after at most 2 fix loops. Writes a "Code review" section for the PR body; never posts inline comments. Called by the runner after the checks pass. Use for /review-loop <issue>, "review this change".
argument-hint: <issue number> [base branch]
---

# Review loop

A second pair of eyes before the PR goes out. The reviewer is a **fresh session**: it never sees
the coding conversation, only the issue, the change and the check results. It reads and runs
things; it never edits code.

Model: the `review` choice from the `route` skill (default Sonnet 5.5, high effort).

## The loop

```
review ─ no findings ──────────────────────────────> pass (done in one go)
   └─ findings ─> coder fixes ─> checks ─> review again   (loop 1)
                                              └─ findings ─> coder fixes ─> checks ─> final review   (loop 2)
```

**At most 2 loops.** Finish in one pass whenever the change is good.

## 1. Gather

- The issue: body, groomed section ("Done when", "Where to look", "Tests", "Out of scope",
  "Agent hints"), and its parent or sub-issues.
- The change: `git diff <base>...HEAD` plus uncommitted changes (`git diff`, `git status`, and read
  new untracked files). On loop 2, also the diff since the last review.
- The check results the runner already has.
- The repo's `CLAUDE.md`, and the docs and skills it points to.

## 2. Decide what to check

Use judgement. Check what can go wrong in **this** change, and skip what cannot. Say in the
result what you checked and what you skipped, and why.

| Check | When |
|---|---|
| **Done when + scope** | Always. Every item met; nothing outside the issue changed |
| **Bugs + edge cases** | Any logic, data or state change. Empty input, errors, permissions, regressions in touched code |
| **Project rules + leftovers** | Always. `CLAUDE.md` rules (tenancy, test placement, styling conventions), temp files, debug code, commented-out code, tests added only where the issue's "Tests" section asks |
| **UI in a browser** | Only when the change is visible: components, styles, pages, blocks, images. Skip for server-only or config changes |

## 3. UI check in a browser

1. **Find a browser.** Use the browser tools or skills the app provides (for example a built-in
   browser or a browser extension). If the repo has its own headless-browser scripts, those work
   too. No browser available: skip and say so.
2. **Find how the app runs locally.** Look in this order: `CLAUDE.md` and the docs it points to,
   `README`, the project's skills and memory notes, `package.json` scripts (`dev`), `.env` /
   `.env.local` / `.env.example` for host and port (for example `app.localhost:3000`),
   `docker-compose.yml`. Start the dev server if it is not running.
3. **Look at the change.** Open the page or editor view the issue is about, at desktop and phone
   widths. Compare with the issue, its design or screenshots. Note layout breaks, cut-off content,
   overflow, wrong colors or spacing, broken interactions, console errors.
4. **Clean up.** Undo any test data you created, stop servers you started.

If the app cannot run here (missing secrets, database, services), skip the UI check and say
exactly what was missing. A skipped UI check is not a failure.

## 4. Findings

Every finding sends the change back for a fix, as long as loops remain. Write each one as:

```
- [must-fix | minor] `path/file.ts:42` What is wrong. What to do.
```

`must-fix`: bugs, missed "Done when" items, broken project rules, out-of-scope changes, a visible
UI defect. `minor`: naming, readability, small style points.

## 5. Fix round

Give all findings to the coder (the coding session, not the reviewer). The coder fixes each one,
or explains why not. The runner re-runs the checks. Then review again.

**Disagreement:** when the coder explains instead of fixing, re-check with that reason. Accept
it, or keep the finding. A finding still disputed goes into the PR as **Disputed** for the human
to decide. It does not cost an extra loop.

## 6. After the last review

- **Pass:** no findings left, or only `minor` ones and disputed ones.
- **Stuck:** a `must-fix` finding is still open after loop 2. The runner opens a draft PR and
  labels the issue `needs-human`.

## 7. Output: the PR body only

**No inline PR comments.** Return this section for the runner to put in the PR description:

```markdown
## Code review
**Result:** Passed in 1 pass | Passed after 2 loops | Stuck after 2 loops
**Reviewer:** Sonnet 5.5, high effort, fresh session

**Checked:** Done when, scope, bugs, project rules, UI at app.localhost:3000/… (desktop, phone)
**Skipped:** <check>: <why>

**Fixed during review**
- `file:line` what was wrong → what changed

**Disputed** (your call)
- finding, coder's reason, reviewer's view

**Open notes** (minor, not fixed)
- …
```

Leave out empty parts. Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.
