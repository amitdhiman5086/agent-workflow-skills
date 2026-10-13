---
name: capture
description: Turn a rough idea, screenshots, links or meeting notes into well-formed GitHub issue drafts for the current repo, check for duplicates, and create them after confirmation with the `captured` label. First step of the team workflow (capture → size → groom → agent). Use for /capture, "capture this", "log this idea", "turn these notes into issues".
argument-hint: <idea, notes, or links>
---

# Capture

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Turn what the user gives you into clear GitHub issues. Capture records **what** and **why**.
It does not plan the work: sizing, breakdown and the detailed "Done when" come later in
`/size` and `/groom`.

Input: $ARGUMENTS (plus any images or links in the conversation)

## 1. Know the repo

- `gh repo view --json nameWithOwner` — the repo of the current folder. If there is none, ask
  which repo.
- Skim `CLAUDE.md` so issues use the project's own words.
- `gh issue list --state all --limit 5 --json title,body` — match how this team writes issues.

## 2. Understand the input

Accept any mix of:

- **Rough text** — use it as the core.
- **Screenshots / images** — describe what they show in words (the issue must make sense
  without the image). GitHub's CLI cannot upload images, so after creating the issue tell the
  user to drag the image into it.
- **Links** — open them when you can (GitHub issues/PRs with `gh`, web pages with the
  browser tools). Quote only what matters.
- **Meeting notes / long text** — find each separate idea. List them as one short line each and
  let the user pick which become issues. One idea = one issue.

If something that changes the issue is unclear (which page, what is wrong, who is affected),
ask **at most 3 short questions** in one message. Do not ask what you can find in the code.

## 3. Light code check

For each idea, spend a few searches only:

- Find the main file(s) or page involved, so the issue can point at them.
- For a bug, confirm the problem can exist in the code as described. Say "likely" when not sure.

Do not trace root causes or plan a fix. That is `/groom`'s job.

## 4. Check for duplicates

`gh issue list --state open --search "<key words>" --json number,title --limit 10`

Show possible matches. If one looks like the same thing, ask: update that issue, or create a
new one anyway.

Search sub-issues too (`gh api repos/{owner}/{repo}/issues/<n>/sub_issues`). Prefer adding to an
existing issue over a new one, but only when the idea is the **same scope**. A new area (other
table, action or page) is a new issue that links the related ones.

A plain comment is not seen by every routine. Runner ignores issue comments, and Groom re-reads
only `needs-grooming` and `needs-info` issues. Pick the way to add by the issue's label:

| Label on the matching issue | How to add the idea |
|---|---|
| none, `captured`, `needs-grooming`, `needs-info` | Comment starting with `<!-- capture:addendum -->`. Set `needs-grooming` if missing. |
| `agent-groomed`, `agent-ready` | Same comment, then swap the label to `needs-grooming` so Groom folds it into "Done when". Tell the user the issue goes back through review. |
| `agent-working` (no PR yet) | Runner will not see it. Create a new issue linked to it, or wait for the PR. |
| `agent-pr-ready`, `needs-human` (open PR) | Comment `/agent-improve <what>` on the PR as the owner. Runner picks it up next run. |
| closed | New issue that links the closed one. |

Show the comment and any label change, and get a clear yes before posting.

## 5. Draft

Title: short, specific, under 70 characters, no "[Bug]" prefix.

```markdown
## What
What is wanted or what is wrong, in 1–3 sentences.

## Why
Who it affects and why it matters.

## Details
- For bugs: steps to reproduce, expected, actual.
- What the screenshots or links show.
- Main files or pages involved (`path/to/file.ts`), if found.

## Open questions
- Anything still unknown, for /groom to resolve. Leave out if none.
```

Rules: plain language, no filler, no secrets or `.env` values, no customer data.
Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.

## 6. Confirm, then create

Show every draft (title + body). Ask **"Create these issues?"** and wait for a clear yes.
Creating issues is visible to the whole team. Apply any edits first.

The first time in a repo, check the label exists:
`gh label list --search captured`. If it is missing, ask before creating it:
`gh label create captured --color c5def5 --description "Captured, waiting for size and groom"`.

Then for each draft, write the body to a temp file and run:

```
gh issue create --title "<title>" --body-file <file> --label captured
```

## 7. Size them

Right away, run the `size` skill on every issue you just created. It labels each issue and
splits large ones into sub-issues without asking.

## 8. Report

One line per issue: number, title, link, and the size `/size` gave it. Remind the user to attach
any screenshots by hand. Next, the Groom routine picks them up (label `needs-grooming`).
