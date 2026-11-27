---
name: size
description: Rate a GitHub issue S, M or L from effort and files touched, label it, and split L issues into up to 6 ordered vertical-slice sub-issues. Runs automatically after capture and hands off with needs-grooming. Use for /size <issue>, "size this issue", "break this issue down".
argument-hint: "<issue number or link>"
---

# Size

Follow `../../references/rules.md` when present: terse bullets only, comments 1–2 lines, max 1-line narration between tool calls, and **never mention cost, tokens, or spend on GitHub**.

Runs **unattended** (labels and creates sub-issues without asking, guarded by the rules below).

Input: `$ARGUMENTS` (issue numbers or links).

## 1. Read & guard
```bash
gh repo view --json nameWithOwner
gh issue view <n> --json number,title,body,labels,state,url
gh api repos/{owner}/{repo}/issues/<n>/sub_issues --jq 'length'
```
Skip without changes when the issue is closed, or already has `size:S|M|L` or sub-issues (unless the user explicitly asked to re-size).

## 2. Estimate (targeted scan only)
Locate likely touched files and layers without designing the solution:

| Size | Effort | Files | Typical |
|---|---|---|---|
| **S** | < 2 hours | 1–3 | Single component, bug fix, style/copy tweak |
| **M** | ≤ 1 day | < 10 | Feature across 1–2 areas |
| **L** | > 1 day | 10+ | Cross-stack UI + server + DB flow, or major template/module |

**Bump one size up** for DB migrations, tenant-scoped access, or unclear requirements. When effort and file count disagree, pick the larger size.

## 3. Label & stamp
Ensure `needs-grooming`, `size:S`, `size:M`, `size:L` exist (colors/descriptions in `manifest.json`). Add `size:<X>` + `needs-grooming`, remove `captured`, and append **one compact line** to the issue body:

```markdown
<!-- size -->
**Size: M** — ~5 files in `path/a/` and `path/b/`.
```

## 4. Split `L` into sub-issues (max 6)
Rules for every sub-issue:
- Rated `S` or `M`, independently buildable and mergeable with tests included.
- **Vertical slices** (thin end-to-end path across needed layers; never one per layer), except wide mechanical renames (add beside old → migrate callers in batches → remove old).
- Order: prep refactor first, then dependencies, then riskiest slice first.
- **Over 6 slices (`XL`)**: create **none**. Swap `needs-grooming` → `needs-info` and post a 2-line `<!-- groom:question -->` comment recommending `/wayfinder #<n>` or splitting into 2+ parent issues with your suggested grouping.

Create in order and attach natively:
```bash
gh issue create --title "<title>" --body-file <file> --label needs-grooming --label size:<S|M>
id=$(gh api repos/{owner}/{repo}/issues/<new> --jq .id)
gh api -X POST repos/{owner}/{repo}/issues/<parent>/sub_issues -F sub_issue_id=$id
```

Sub-issue body (<60 words):
```markdown
Part of #<parent>. Depends on: #<prev | nothing>.

## What
<1–2 sentences on the vertical slice>

## Main files
- `path/to/file.ts`

<!-- size -->
**Size: S** — <short reason>.
```

Append `## Breakdown` (`1. #<a> <title> (S)`) to the parent body.

## 5. Report
1 line per issue (`#<n> size:<X> — <reason>`, plus ordered sub-issues for `L`).
