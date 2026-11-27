---
name: capture
description: Turn a rough idea, screenshots, links or meeting notes into concise GitHub issue drafts, align in short grill-me rounds, check duplicates, create issues with the captured label, and run size. First step of the workflow. Use for /capture, "capture this", "log this idea", "turn these notes into issues".
argument-hint: "<idea, notes, or links>"
---

# Capture

Follow `../../references/rules.md` when present: terse bullets only, issue bodies under 100 words, comments 1–2 lines, max 1-line narration between tool calls, and **never mention cost, tokens, or spend on GitHub**.

Capture records **what** and **why**, then hands off to `/size` and `/groom`.

Input: `$ARGUMENTS` (plus any images or links in chat).

## 1. Know the repo
- `gh repo view --json nameWithOwner` (or host GitHub tools). Ask which repo if none.
- Skim `AGENTS.md` (fallback `CLAUDE.md`, `GEMINI.md`) to use project terminology.
- `gh issue list --state all --limit 5 --json title,body` to match local conventions.

## 2. Parse the input
- **Rough text**: extract core intent.
- **Screenshots / images**: describe visible state in plain words so the issue stands without the image. Remind the user to drag images into the created issue (`gh` cannot upload attachments).
- **Links**: inspect with `gh` or browser/fetch tools; quote only essential facts.
- **Meeting notes / multi-item dump**: list 1 line per distinct idea and let the user pick which become issues (1 idea = 1 issue).
- **XL / high-uncertainty epic**: if an idea clearly spans >6 slices with unresolved architectural choices, suggest running `/wayfinder` first before drafting build issues.

## 3. Fast code check
Spend 2–3 targeted searches to name the primary `path/to/file` or route, and check if a reported bug is plausible in code (`likely` when unconfirmed). Leave root-cause tracing and design to `/groom`.

## 4. Align (`grill-me`)
Skip if already unambiguous. Otherwise follow `grill-me`: frontier rounds of numbered 1–2 sentence questions, each with a `➡️` recommended answer that `"yes"` accepts. Ask only product/scope/design decisions; look up code and tracker facts yourself.

## 5. Check duplicates & sub-issues
```bash
gh issue list --state open --search "<keywords>" --json number,title --limit 10
```
Also inspect sub-issues (`gh api repos/{owner}/{repo}/issues/<n>/sub_issues`) when a parent matches. Fold into an existing issue only when it is the **same scope**; otherwise link as a new issue.

| Existing issue label | How to fold in (confirm before posting) |
|---|---|
| none, `captured`, `needs-grooming`, `needs-info` | Comment starting `<!-- capture:addendum -->`; add `needs-grooming` and remove `captured` / `needs-info` |
| `agent-groomed`, `agent-ready` | Same comment; add `needs-grooming` and remove `agent-groomed` / `agent-ready` so Groom updates `Done when` |
| `agent-working` (no PR) | Create a linked issue or wait for the PR |
| `agent-pr-ready`, `needs-human` (open PR) | Comment `/agent-improve <what>` on the PR |
| closed | New issue linking the closed one |

## 6. Draft (<100 words, omit empty sections)
Title: specific, under 70 chars, no `[Bug]` prefix. No secrets, `.env` values, customer data, or cost/token mentions.

```markdown
## What
1–2 sentences on what is wanted or broken.

## Why
1 sentence on who it affects and why it matters.

## Details
- Repro / expected vs actual (bugs), or key screenshot facts.
- Main files: `path/to/file.ts`

## Agreed
- Scope, rough done state, non-goals, copy/design choices.

## Open questions
- Only decisions explicitly deferred to `/groom`.
```

## 7. Confirm, create, and size
Show drafts and ask **"Create these issues?"** Wait for an explicit yes. Ensure `captured` exists (from `manifest.json` / `workflow-setup` label list; ask once before creating). Create with:
```bash
gh issue create --title "<title>" --body-file <file> --label captured
```
Immediately run `size` on every created issue, then report 1 line per issue (`#<n> <title> (<url>) — <size>`) and remind the user to attach any screenshots.
