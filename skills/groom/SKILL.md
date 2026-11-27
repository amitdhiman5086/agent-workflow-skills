---
name: groom
description: Make GitHub issues agent-ready. Unattended routine that picks up needs-grooming (and answered needs-info) issues, verifies code/bugs, settles technical rulings, writes a compact context pack and Route hint, and marks agent-groomed. Max 5 issues per run. Use for /groom, /groom <issue>, "groom the backlog".
argument-hint: "[issue number] (empty = oldest waiting, max 5)"
---

# Groom

Follow `../../references/rules.md` when present: groomed block under 120 words, comments 1–2 lines, max 1-line narration between tool calls, and **never mention cost, tokens, or spend on GitHub**.

Runs unattended on the **`deep`** model tier (strongest reasoning model available).

## 1. Pick work (max 5, oldest first; parent + sub-issues = 1)
With an argument: groom that issue (and its sub-issues). Without one, collect open issues:
1. Labelled `needs-grooming`.
2. Labelled `needs-info` whose newest comment is newer than the latest `<!-- groom:question -->` comment and not authored by Groom/Size (`yes` accepts all recommendations; `Q2: b` selects an option).

**Never touch** closed issues, issues labelled `agent-ready` or `agent-working`, or issues with an open linked PR.

## 2. Verify in code
- Read issue body, comments, parent/sub-issues, and `AGENTS.md` (fallback `CLAUDE.md`, `GEMINI.md`).
- Treat `/capture`'s `Agreed` bullets as settled.
- **Already implemented?** Search by behavior. If present, ask via `needs-info` whether to close, citing `file:line`.
- **Bug?** Reproduce cheaply or trace exact code path; record `Reproduced: ...` or `Code path: ...` in `Where to look`.

## 3. Rulings, not stalls
Settle technical choices yourself from code and repo conventions; list non-obvious ones as 1-line `Ruling:` bullets under `Agent hints`.

Stop with `needs-info` **only** when code cannot answer (product/UX choice, missing copy/design, missing external access, contradictory spec):
- Post 1 comment starting `<!-- groom:question -->` mentioning the author, using terse `grill-me` questions (1–2 sentences each + `➡️` recommendation, ending `"Reply yes to accept all, or Q1: ..."`).
- Swap `needs-grooming` → `needs-info` and move on.

## 4. Re-check size & breakdown
Adjust `size:S|M|L` or split/merge/reorder sub-issues freely (each `S` or `M`, ≤6 vertical slices; if >6, swap to `needs-info` and recommend `/wayfinder #<n>`). Groom any newly created sub-issues in the same run.

## 5. Write replaceable Context Pack (<120 words, omit empty parts)
Insert or replace between `<!-- groom:start -->` and `<!-- groom:end -->` (downstream builders read `Where to look` directly instead of re-searching the repo):

```markdown
<!-- groom:start -->
## Done when
- [ ] Checkable outcome (command or visible behavior).

## Where to look
- `path/file.ts:40-72` (`symbol`): current behavior → required change.
- Pattern: `path/similar.ts:10-30`

## Tests
- Named cases to add, or `None — verify by: <exact step>`.

## Out of scope
- Boundaries not to touch.

## Agent hints
- Type: <bug | feature | refactor>
- Route: plan <none|deep> · code <standard|deep> · review <single|dual> (<standard|deep>)
- Base: <branch>   <!-- omit when default -->
- Rulings / Risks: <1 line per ruling or repo rule that applies>
<!-- groom:end -->
```

**Choosing `Route`:**
- `plan`: `none` for `size:S` or clear single-root-cause `bug`; `deep` for `M`/`L`.
- `code`: `standard` by default; `deep` only for complex algorithms/concurrency.
- `review`: `single (standard)` by default; `dual (deep)` for auth, security, tenancy, DB migrations, or irreversible contracts.

## 6. Hand off (zero-noise)
Add `agent-groomed` and remove both `needs-grooming` and `needs-info`.
- **If size or sub-issues changed**: post 1 comment (`<!-- groom:done -->`): `Size/breakdown updated: <1-line diff>. Ready for review → agent-ready.`
- **If nothing structural changed**: post **no comment** (the updated body + `agent-groomed` label are enough).

## 7. Report
1 line per issue: `#<n> → <agent-groomed | needs-info | skipped> (<size>, <changes or none>)`.
