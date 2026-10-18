---
name: review-loop
description: Review an agent's change in fresh, separate sessions before the PR opens. A Spec reviewer (Done when, scope, bugs) and a Standards reviewer (project rules, leftovers, code smells) run in parallel, each judging which checks matter, plus the UI in a real browser when the change is visual. Findings rest on what the reviewer ran or read, never on the coder's word. Sends every finding back to the coder, and stop after at most 2 fix loops. Writes a "Code review" section for the PR body; never posts inline comments. Called by the runner after the checks pass. Use for /review-loop <issue>, "review this change".
argument-hint: <issue number> [base branch]
---

# Review loop

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

A second pair of eyes before the PR goes out. Each reviewer is a **fresh session**: it never
sees the coding conversation, only the issue, the change and the check results. It reads and runs
things; it never edits code.

Based in part on Matt Pocock's `code-review` and pstack's `principle-prove-it-works` (MIT).

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

## 2. Two reviewers, in parallel

Start two fresh review sub-sessions at the same time, on the route's `review` model. Give each the
diff and the issue; give the Standards reviewer the rule files and the smell list too. Keep their
findings in separate lists. Never merge or re-rank them: a change can pass one and fail the other.

Each reviewer uses judgement: check what can go wrong in **this** change, skip what cannot, and
say what was checked and skipped, and why.

**Spec reviewer: does the change do what the issue asks?**
- Every "Done when" item is met. Quote the item in each finding.
- Missing or partial items; behavior nobody asked for (scope creep); items that look done but
  work wrong.
- Bugs and edge cases in changed logic, data or state: empty input, errors, permissions,
  regressions in touched code.

**Standards reviewer: does the change follow this repo's rules?**
- `CLAUDE.md` and every doc that says how code is written (`CONTRIBUTING.md`,
  `CODING_STANDARDS.md`, the docs `CLAUDE.md` points to): tenancy, test placement, styling. Cite
  the rule in each finding.
- Leftovers: temp files, debug code, commented-out code, comments that repeat the code, tests
  beyond what the issue's "Tests" section asks.
- Code smells, as judgement calls: always `minor`, and a documented repo rule wins over them.
  - Mysterious name: the name does not say what it does or holds.
  - Duplicated code: the same logic in two places in the change.
  - Feature envy: a function that mostly uses another module's data.
  - Data clumps: the same few values always passed together.
  - Primitive obsession: a plain string or number standing in for a domain idea.
  - Repeated switches: the same `switch` or `if` chain on the same value in several places.
  - Shotgun surgery: one logical change spread across many files.
  - Speculative generality: options, hooks or abstractions the issue does not need.
  - Middle man: a function or class that only passes calls on.
  - Message chains: long `a.b().c().d()` walks the caller should not depend on.

**UI in a browser** (step 3): the main review session does it once, only when the change is
visible (components, styles, pages, blocks, images). Skip it for server-only or config changes.

**Prove it.** Base every finding and every pass on something you ran or read: the code at
`file:line`, a test or command you ran, the page you opened. Never on the coder's summary or a
check you did not see. For a failure, quote the output that shows it, not only "test fails".

## 3. UI check in a browser

1. **Find a browser.** Use the browser tools or skills the app provides (for example a built-in
   browser or a browser extension). If the repo has its own headless-browser scripts, those work
   too. No browser available: skip and say so.
2. **Find how the app runs locally.** Look in this order: `CLAUDE.md` and the docs it points to,
   `README`, the project's skills and memory notes, `package.json` scripts (`dev`), `.env` /
   `.env.local` / `.env.example` for host and port (for example `app.localhost:3000`),
   `docker-compose.yml`. Start the dev server if it is not running.
   - **Run the code under review.** In a git worktree, start the server from that worktree, not
     the main clone. A server already running from the main clone shows other code. Use a port
     that clashes with no running server (the runner's setup records one).
   - **Copied env files keep the old port.** After copying `.env` files into a worktree, change
     every URL in them that names the main clone's port (app domain, auth callback). Otherwise
     redirects and login go to the other server.
   - **Open the host the env names.** Multi-tenant apps route bare `localhost` as a customer site
     and answer with an error that looks like a bug. Use the app host from the env (for example
     `app.localhost:<port>`).
3. **Look at the change.** Open the page or editor view the issue is about, at desktop and phone
   widths. Compare with the issue, its design or screenshots. Note layout breaks, cut-off content,
   overflow, wrong colors or spacing, broken interactions, console errors.
4. **Screenshots.** On the final review pass, save one desktop and one phone screenshot of each
   changed screen as PNG in the worktree's `.screenshots/` folder (add `.screenshots/` to
   `.git/info/exclude` so it is never committed). Name them `<screen>-desktop.png`,
   `<screen>-mobile.png`. Return the paths with a one-line caption each; the runner posts them.
5. **Clean up.** Undo any test data you created, stop servers you started.

If the app cannot run here (missing secrets, database, services), skip the UI check and say
exactly what was missing. A skipped UI check is not a failure.

## 4. Findings

Every finding sends the change back for a fix, as long as loops remain. Write each one as:

```
- [must-fix | minor] [Spec | Standards] `path/file.ts:42` What is wrong. What to do.
```

`must-fix`: bugs, missed "Done when" items, broken project rules, out-of-scope changes, a visible
UI defect. `minor`: naming, readability, small style points, code smells.

## 5. Fix round

Give all findings to the coder (the coding session, not the reviewers). The coder fixes each
one, or explains why not. The runner re-runs the checks. Then both reviewers review again.

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
**Reviewers:** Spec and Standards, <model>, <effort>, fresh sessions

**Checked:** Spec (Done when, scope, bugs), Standards (project rules, leftovers, smells), UI at app.localhost:3000/… (desktop, phone)
**Skipped:** <check>: <why>

**Fixed during review**
- [Spec | Standards] `file:line` what was wrong → what changed

**Disputed** (your call)
- finding, coder's reason, reviewer's view

**Open notes** (minor, not fixed)
- …
```

Leave out empty parts. Return the screenshot paths and captions separately, not in this section.
Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.
