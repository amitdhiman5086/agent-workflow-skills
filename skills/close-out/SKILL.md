---
name: close-out
description: Tidy GitHub after an agent PR merges or closes. Merged PRs close the issue and resolved sub-issues with a single 1-line summary, close finished parents, remove workflow labels, and delete the runner branch. Unmerged closed PRs set needs-human. Runs automatically at the start of runner. Use for /close-out, /close-out <PR or issue>.
argument-hint: "[PR or issue number]"
---

# Close-out

Follow `../../references/rules.md` when present: comments 1–2 lines, and **never mention cost, tokens, or spend on GitHub**.

## 1. Locate non-open PRs
- **Routine mode** (no argument): inspect `--state all` issues assigned to owner that still carry `agent-pr-ready` or `needs-human` (including issues GitHub auto-closed on default-branch merge) whose linked PR body contains `<!-- runner -->`:
  ```bash
  gh pr view <pr> --json state,mergedAt,baseRefName,headRefName,closingIssuesReferences,body,changedFiles,additions,deletions
  ```
  Skip PRs still `OPEN`, or closed unmerged PRs already recorded with `<!-- close-out:pr-<pr> -->` on the issue.
- **Manual mode** (`/close-out <number>`): inspect that PR (or issue's PR), preview actions, and confirm with the user first when it is not an `<!-- runner -->` PR.

## 2. Merged PR (single concise comment, no metrics table)
1. Collect target issue + any issues in `Closes #` / `Resolves #` / `closingIssuesReferences`.
2. For each finished issue: post `<!-- close-out:pr-<pr> --> ✅ Merged in #<pr> (\`<base>\`) · <changedFiles> files (+<additions>/−<deletions>).` (append `"Reaches \`<main>\` via #<open-pr>."` if `<base>` is a feature branch), and close the issue if still open (`gh issue close <n> --reason completed`).
3. If closed issue has a parent (`repos/{owner}/{repo}/issues/<n>/parent`) and all sibling `sub_issues` are now closed, close the parent with `"✅ All sub-issues merged."`
4. Remove `agent-pr-ready`, `agent-working`, `needs-human` from every closed issue.
5. Delete remote branch **only** if PR has `<!-- runner -->`, branch starts with owner's prefix, and no open PR uses it as head or base:
   ```bash
   gh api -X DELETE repos/{owner}/{repo}/git/refs/heads/<branch>
   ```

## 3. Closed without merging
Keep issue open and branch intact; swap `agent-pr-ready` → `needs-human`; post 1 line once:
`<!-- close-out:pr-<pr> --> PR #<pr> closed unmerged (branch \`<branch>\` kept). Reply /agent-retry to rebuild or re-groom.`

## 4. Report
1 line per PR: `#<pr> <merged|closed> → closed <issues>, branch <deleted|kept>`.
