---
name: close-out
description: Finish the agent workflow after a PR leaves the open state. Merged into its target branch, it closes the issue and its sub-issues, closes the parent when its last sub-issue is done, deletes the runner's branch on GitHub and posts a metrics summary. Closed without merging, it labels the issue needs-human and keeps the branch. Runs at the start of every runner routine run; also by hand for any merged PR. Use for /close-out, /close-out <PR or issue>.
argument-hint: "[PR or issue number] (empty = all of the owner's agent PRs)"
---

# Close-out

The last step: once a PR is merged (or closed), tidy up GitHub so the issue list shows the truth.

GitHub access: `gh` when available, otherwise the app's GitHub tools. Write comments in plain
English. Never mention cost, tokens or spend; use the result metrics below.

## 1. Find the PRs

**Routine mode** (no argument, called at the start of every runner run): issues assigned to the
owner and labelled `agent-pr-ready` or `needs-human`, whose PR was opened by the runner (its body
contains `<!-- runner -->`). Check each PR's state:

```
gh pr view <pr> --json state,mergedAt,baseRefName,headRefName,closingIssuesReferences,body,files,additions,deletions
```

Still open: skip.

**By hand** (`/close-out <number>`): any PR, or the PR linked to an issue. Show what you are about
to close and wait for a yes, since this PR may not be the runner's.

## 2. Merged

"Done" means merged into the PR's target branch, whatever that branch is (`develop` or a feature
branch).

1. **Which issues it finishes:** the issue it was built for, plus every issue in its `Closes #` /
   `Resolves #` lines and its `closingIssuesReferences`. Nothing else: an issue the PR did not
   claim (for example an open question) stays open.
2. **Close each one** that is still open, with a short comment:
   `gh issue close <n> --reason completed --comment "Done in #<pr>, merged into \`<base>\`."`
   If `<base>` is a feature branch with an open PR into the main branch, add:
   "It reaches `<main branch>` with #<that PR>."
3. **Close the parent** when the issue has one and all the parent's sub-issues are now closed:
   `gh api repos/{owner}/{repo}/issues/<n>/parent`, then its `.../sub_issues`. Comment "All
   sub-issues done." Leave the parent open while any sub-issue is still open.
4. **Remove the workflow labels** from every closed issue: `agent-pr-ready`, `agent-working`,
   `needs-human`.
5. **Delete the branch on GitHub**, only when all of these hold: the runner created it (its PR
   body contains `<!-- runner -->` and the branch starts with the owner's prefix), and no open PR
   uses it as its base or head.
   `gh api -X DELETE repos/{owner}/{repo}/git/refs/heads/<branch>`
6. **Post a metrics summary** on the main issue, one comment:

```markdown
✅ Merged in #<pr> into `<base>`.

| | |
|---|---|
| Size | M |
| Agent-ready → merged | 1 day 3 h |
| Files changed | 8 (+412 / −37) |
| Checks | typecheck, tests, lint |
| Fix attempts | 1 |
| Review loops | 1 (passed) |
| Feedback rounds | 2 |
| Sub-issues closed | #301, #302 |
```

Where the numbers come from: size from the `size:*` label; time from when `agent-ready` was added
(`.../issues/<n>/events`) to `mergedAt`; files and lines from the PR; checks, fix attempts and the
review result from the PR body; feedback rounds = the runner's replies to `/agent-…` commands.
Leave out a row you cannot fill.

## 3. Closed without merging

- Keep the issue open and keep the branch.
- Swap `agent-pr-ready` → `needs-human`.
- Comment: "PR #<pr> was closed without merging. The branch `<branch>` is kept. Reply
  `/agent-retry` to rebuild, or move the issue back to grooming."

## 4. Report

One line per PR: number, merged or closed, issues closed, branch deleted or kept.
