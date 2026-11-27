---
name: review-loop
description: Review a change in fresh, context-isolated session(s) before opening a PR. Runs a single combined reviewer by default or dual parallel Spec + Adversarial Standards reviewers for high-risk changes, plus live browser UI checks when visual files changed. Loops only on must-fix items (max 2). Use for /review-loop <issue>.
argument-hint: "<issue number> [base branch]"
---

# Review loop

Based on Matt Pocock's `code-review`, pstack's `principle-prove-it-works`, and Addy Osmani's `doubt-driven-development` (MIT). Follow `../../references/rules.md` when present: **never mention cost, tokens, or spend on GitHub**.

Reviewers run in **fresh sessions** with zero memory of the coding conversation — they receive only the issue spec, repo rule files, diff, and check output, and never edit code.

## 1. Diff-scoped preflight (shell first)
1. Inspect `git diff --name-only <base>...HEAD` (plus uncommitted/untracked files).
2. Classify changed paths:
   - **Visual files touched?** (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`, `.html`, templates, blocks, images) → enable Step 3 browser UI check; otherwise **skip browser check immediately**.

## 2. Fresh review (`single` vs `dual` from `route`)
Every claim must cite concrete proof (`path/file.ts:42`, command output, or browser observation) — never trust the coder's summary.

- **`single` mode (default for `S`/`M` normal changes)**: launch **1 fresh reviewer** checking both Spec and Repo Standards.
- **`dual` mode (auth, security, tenancy, DB migrations, public contracts)**: launch **2 fresh reviewers in parallel**:
  1. **Spec reviewer**: every `Done when` item met (quote it), no scope creep, edge-case/state/error bugs in changed code.
  2. **Adversarial Doubt & Standards reviewer**: biased to disprove invariants, auth/tenancy isolation, migration safety, and adherence to `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` / `CONTRIBUTING.md`, plus leftover debug/temp artifacts.

Classify findings strictly:
```text
- [must-fix | minor] `path/file.ts:42` <problem> → <fix>
```
- **`must-fix`**: bug, missed `Done when`, broken documented repo rule, out-of-scope change, security/tenancy flaw, or visible UI defect.
- **`minor`**: naming, style preference, or non-rule code smell.

## 3. Live browser UI check (visual diffs only)
1. Read `AGENTS.md`/`CLAUDE.md`/`GEMINI.md`, `package.json`, and `.env` / `.env.local` / `.env.example` (plus runner `UI preview` config) for exact local host and port (e.g. `app.localhost:<port>`).
2. In a git worktree, run the dev server from **that worktree** on a non-conflicting port and rewrite copied `.env` callback/domain ports so redirects stay on the worktree server.
3. Inspect changed views at desktop and mobile widths for layout breaks, overflow, broken interactions, and console errors.
4. On the final pass, save `<screen>-desktop.png` and `<screen>-mobile.png` in `.screenshots/` (add `.screenshots/` to `.git/info/exclude`). Clean up test data and stop servers started for the check.
5. If browser tools or required services/secrets are unavailable, record the exact blocker in 1 line and continue.

## 4. `must-fix`-only fix loop (max 2 loops)
- **Zero `must-fix` findings** → **Pass immediately** (`minor` notes **never** trigger a rebuild or re-review loop).
- **One or more `must-fix` findings** (while loops < 2):
  1. Send `must-fix` items to the **coder** session.
  2. Coder fixes each item (or states why it is invalid). Re-run checks.
  3. Fresh reviewer re-verifies the updated diff. If a coder pushback remains contested, mark it **`Disputed`** for the human without spending another loop.
- **Open `must-fix` after loop 2** → **Stuck** (`runner` opens draft PR + `needs-human`).

## 5. Lean handoff to `runner` (no PR audit essays)
Do **not** post inline PR comments or verbose `Checked/Skipped/Fixed` logs. Return only:
- `Status`: `pass` | `stuck`
- `Risk`: `Two-way` | `One-way (<migration, env, or contract reason>)`
- `Disputed`: 1 bullet per unresolved coder/reviewer disagreement *(omit if none)*
- `Screenshots`: `.screenshots/*.png` paths + 5-word captions *(omit if none)*
- `Rule candidate`: on `/agent-improve` runs caused by an undocumented repo convention, 1 proposed bullet for `AGENTS.md` *(omit otherwise)*
