---
name: groom
description: Make GitHub issues agent-ready. Picks up issues labelled needs-grooming (and needs-info issues that got an answer), re-checks size and sub-issues with fresh judgement, writes Done when, where to look, tests, out of scope and agent hints, then hands them to a human with the agent-groomed label. Stops with needs-info when only a human can decide. Third step of the team workflow (capture → size → groom → human → agent). Runs as a scheduled routine, max 5 issues per run. Use for /groom, /groom <issue>, "groom the backlog".
argument-hint: "[issue number] (empty = everything waiting, max 5)"
---

# Groom

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

## Labels

Label names in this skill are roles. The repo may use its own label for a role.
- Read the `## Labels` section of the local settings file
  `~/.config/agent-workflow/<owner>/<repo>.md` (`<owner>/<repo>` from
  `gh repo view --json nameWithOwner`).
- Use the repo's label for each role everywhere: `gh` commands, searches and comments. A role
  missing from the file uses its role name.
- No file yet: never create a label, since one with the same meaning may exist. Run the label
  matching in the `workflow-setup` skill (Phase 4) first.

Turn sized issues into issues an agent can finish without asking a single question.
Groom runs unattended (a scheduled routine), so it acts on its own and explains every change in
a comment. Nobody answers questions during a run.

Recommended model: the most capable one available, high effort (e.g. Opus 5.5, high).

## Label flow

```
/capture ─> captured ─/size─> needs-grooming ─Groom─> agent-groomed ─you─> agent-ready
                                                 │
                                                 └─> needs-info ─(someone answers)─> Groom again
```

## GitHub access

Use `gh` when it is installed and logged in. Otherwise use the GitHub tools or connector of the
app you run in. The `gh` commands below show exactly what to do.

## 1. Pick the work

With an issue number: groom that issue (and its sub-issues if it is a parent).

Without one, in the current repo, collect:

1. Open issues labelled `needs-grooming`.
2. Open issues labelled `needs-info` whose newest comment is newer than Groom's question
   comment (marked `<!-- groom:question -->`) and is not from Groom. Treat them as
   `needs-grooming` again. A reply of `yes` accepts every recommendation in the question
   comment; `Q2: b` picks an option.

```
gh issue list --label needs-grooming --state open --json number,title,createdAt --limit 50
gh issue list --label needs-info --state open --json number --limit 50
```

Oldest first. **At most 5 per run.** A parent and its sub-issues count as one. The rest wait for
the next run.

**Never touch** an issue that is closed, labelled `agent-ready` or `agent-working`, or has an
open PR linked to it.

## 2. Understand it

- Read the issue body, its comments, its parent (`gh api repos/{owner}/{repo}/issues/<n>/parent`)
  and its sub-issues (`.../sub_issues`).
- Read the repo's `CLAUDE.md` and the docs and skills it points to.
- Read the code for real: the files involved, similar existing features to copy, tests nearby.
- The issue's "Agreed" section (from `/capture`) holds settled decisions. Never ask them again.
- **Already built?** Search the code for the behavior by what it does, not only by the issue's
  words. If it exists, ask (step 3) whether to close the issue, and say where it lives.
- **A bug?** Confirm it first: reproduce it with a test or a short script when that is cheap,
  otherwise walk the code path step by step. Write the result under "Where to look"
  (`Reproduced: …` or `Code path: …`). If you cannot confirm it and the steps are missing, ask
  (step 3).

## 3. Decide, or ask

Decide technical questions yourself, from the code, existing patterns, the project rules and the
"Agreed" section. Write each decision into the groomed section ("Where to look", "Risks"), so a
human can see it and change it.

Ask only when the code cannot answer and a wrong guess would waste the work: a product choice,
missing design or copy, conflicting requirements, access the agent will not have.

Then:
- Post one comment that starts with `<!-- groom:question -->` and mentions the issue author. Use
  the `grill-me` format: numbered questions, each with its options and your recommended answer.
  End with: "Reply `yes` to accept all recommendations, or answer per question (`Q2: b`)."
- Swap the label `needs-grooming` → `needs-info`. Change nothing else. Move on.

Do **not** stop for things you can find in the code or decide from existing patterns.

## 4. Re-check size and breakdown

You have deeper context than `/size` had. Use the same scale:

| Size | Effort | Files |
|---|---|---|
| S | under 2 hours | 1–3 |
| M | up to 1 day | under 10 |
| L | more than 1 day | 10 or more, or a new design, or UI + server + DB |

One size up for a database migration, tenant-scoped data access, or unclear requirements.

You may change freely, as long as no issue involved is `agent-ready` or later:
- Fix the `size:*` label.
- Split an issue that is really L into sub-issues (each S or M, mergeable alone, vertical
  slices ordered as in `/size`, tests with their code, at most 6).
- Edit, add, reorder or merge sub-issues. Close a wrong sub-issue with
  `gh issue close <n> --reason "not planned"` and a comment saying where its work went.
- Fold an over-split parent back into one issue.

New sub-issues: create in order, then link with
`gh api -X POST repos/{owner}/{repo}/issues/<parent>/sub_issues -F sub_issue_id=<issue .id>`.
Give them `needs-grooming` and groom them in this same run.

## 5. Write the groomed section

Keep the original text (What / Why / Details). Add or **replace** one section between markers,
so grooming again never duplicates it:

```markdown
<!-- groom:start -->
## Done when
- [ ] Each item checkable by running or looking at something. No "works well".

## Where to look
- `path/file.ts:40-72` (`functionName`): what it does now and what changes.
- Pattern to copy: `path/to/similar-feature/`.

## Tests
Add tests only where they protect something: logic, data access, tenant scoping, security,
or a bug that must not come back. Name the cases, e.g. "out-of-scope site returns not found".
Otherwise write: "No new tests. Verify by: <steps in the browser or app>."

## Out of scope
- What must not change.

## Agent hints
- Route: plan <none|opus> · code <sonnet|opus> · review <sonnet|opus>
- Base: <branch>   (only when it should not use the repo's usual base branch)
- Risks: anything the agent must be careful with, and the project rules that apply.
<!-- groom:end -->
```

Choosing the Route line (the runner follows it exactly):
- `plan`: `none` for a clear S; `opus` for everything else. The plan runs on Opus at xhigh
  effort (see the `incremental-build` skill).
- `code`: `sonnet` by default; `opus` only when the coding itself needs deep reasoning.
- `review`: `sonnet` by default; `opus` for security, tenancy or data-loss risk.

For a parent with sub-issues, the parent's section covers the whole result and the order of work;
each sub-issue gets its own section for its piece.

## 6. Hand over to a human

For each groomed issue:
- Swap the label `needs-grooming` → `agent-groomed` (create the label once if missing, see Labels:
  `gh label create agent-groomed --color 0e8a16 --description "Groomed by agent, waiting for human"`,
  same for `needs-info`, color `d93f0b`).
- Post one short comment starting with `<!-- groom:done -->`:
  "Groomed. Size M. Changed: <size or breakdown changes, or 'nothing'>. Review it, then add
  `agent-ready` (or groom it further yourself first)."

Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.

## 7. Report

One line per issue: number, outcome (`agent-groomed`, `needs-info`, skipped), size, changes.
