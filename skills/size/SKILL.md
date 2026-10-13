---
name: size
description: Rate a GitHub issue S, M or L from estimated effort and files touched, label it, and automatically split L issues into ordered native GitHub sub-issues (each S or M, at most 6). Second step of the team workflow (capture → size → groom → agent); runs automatically after /capture and hands issues to the Groom routine with the needs-grooming label. Use for /size <issue>, "size this issue", "break this issue down".
argument-hint: <issue number or link>
---

# Size

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Rate an issue S, M or L, and split L issues into sub-issues. This skill runs **without asking**:
it labels and creates sub-issues on its own, then reports what it did. The guardrails below keep
that safe.

Input: $ARGUMENTS — one or more issue numbers or links. When called from `/capture`, size each
issue it just created.

## 1. Read the issue

```
gh repo view --json nameWithOwner
gh issue view <n> --json number,title,body,labels,url
gh api repos/{owner}/{repo}/issues/<n>/sub_issues --jq 'length'
```

**Skip and report, without changing anything,** when the issue:
- already has a `size:S`, `size:M` or `size:L` label, or already has sub-issues (sized before),
  unless the user explicitly asked to re-size it;
- is closed.

## 2. Estimate (medium research)

Read enough code to answer three questions. Do not plan the fix; that is `/groom`'s job.

1. Which files will change or be added? Count them.
2. Which areas does it touch? (UI, server/actions, database/migrations, blocks/templates,
   tests, previews/assets)
3. How long for one developer working with an agent?

| Size | Effort | Files | Typical |
|---|---|---|---|
| **S** | under 2 hours | 1–3 | One component, a style fix, a copy change |
| **M** | up to 1 day | under 10 | One feature in one or two areas |
| **L** | more than 1 day | 10 or more | A new design or template port, a flow across UI + server + DB |

**Go one size up** when the work includes a database migration, tenant-scoped data access, or
requirements that are still unclear. When effort and file count disagree, use the larger size.

## 3. Label

Make sure the labels exist in the repo. Create any that are missing, once:

```
gh label create needs-grooming --color bfd4f2 --description "Sized, waiting for the Groom routine"
gh label create size:S  --color c2e0c6 --description "Under 2 hours, 1-3 files"
gh label create size:M  --color fef2c0 --description "Up to 1 day, under 10 files"
gh label create size:L  --color f9d0c4 --description "More than 1 day; split into sub-issues"
```

Then on the issue: add `size:<X>` and `needs-grooming`, remove `captured`. The parent of an L
issue gets them too: Groom checks the whole breakdown.

Append a short section to the issue body (keep everything already there):

```markdown
## Size: M
About half a day. Touches ~5 files in `blocks/templates/hero/` and `public/assets/`.
```

## 4. Split L issues into sub-issues

Only for L. Plan the pieces first, then check the rules, then create.

**Rules for each sub-issue**
- S or M on its own. If a piece is still L, split it further.
- Mergeable alone: the app builds and tests pass after it, in order.
- Ordered by dependency: data and schema → server → UI → previews, assets and docs.
- Tests belong with the code they test. No separate "write tests" or "cleanup" sub-issue.
- **At most 6.** If the work needs more, do not create any. Keep the issue as `size:L`, and
  comment that it should become two or more parent issues, with your suggested grouping.
  That case needs a human.

**Create them in order** (native sub-issue order is creation order):

```
gh issue create --title "<title>" --body-file <file> --label needs-grooming --label size:<S|M>
id=$(gh api repos/{owner}/{repo}/issues/<new> --jq .id)
gh api -X POST repos/{owner}/{repo}/issues/<parent>/sub_issues -F sub_issue_id=$id
```

Sub-issue body:

```markdown
Part of #<parent>.

## What
The one piece this sub-issue delivers.

## Depends on
#<earlier sub-issue>, or "nothing".

## Main files
- `path/to/file.ts`

## Size: S
One line of reasoning.
```

Then append to the parent body:

```markdown
## Breakdown
1. #<a> <title> (S)
2. #<b> <title> (M)
```

Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.

## 5. Report

One line per issue: number, size, one-line reason. For L issues, list the sub-issues created
in order. Next: the Groom routine picks them up on its next run (or run `/groom <number>`).
