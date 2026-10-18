---
name: incremental-build
description: Build a change in thin, verified slices. First a deep plan in its own sub-session on the strongest model (Opus, xhigh effort) that splits the work into vertical slices, riskiest first. Then for each slice: write the named failing test first, build, run typecheck and the related tests, commit, and only then start the next. Keeps comments rare and lists what it noticed but did not change. Used by the runner for its plan and code phases; also by hand. Use for /incremental-build <issue or task>, "build this step by step", "small commits".
argument-hint: <issue number or task>
---

# Incremental build

Based on Addy Osmani's `incremental-implementation`, pstack's
`principle-sequence-verifiable-units` and Matt Pocock's `tdd` (all MIT).

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Plan deeply once, then build in small steps that each end green and committed. A break is then
caught in the slice that caused it, and every commit can be reviewed or reverted on its own.

Input: $ARGUMENTS. An issue: read its body and the groomed section ("Done when", "Where to
look", "Tests", "Out of scope", "Agent hints"). A task: the user's description.

**Checks:** the ones the runner passes in; otherwise the `## Runner` section of the local
settings file `~/.config/agent-workflow/<owner>/<repo>.md`; otherwise propose them from
`package.json` scripts and `CLAUDE.md`.

## 1. Plan (deep thinking)

Skip the plan only when the route says `plan none` (a clear S issue). The whole change is then
one slice.

Run the plan in its own sub-session on the strongest model at extra-high effort (Claude Code:
the agent tool with `model: opus` and `effort: xhigh`). In another tool, use its strongest
reasoning model at its highest effort. The planner reads the issue, `CLAUDE.md` and the code. It
changes nothing.

```markdown
## Plan
Goal: <one line>
Risks: <what can go wrong; the project rules that apply>

1. <slice title>: <what works after this slice>
   Files: `path/a.ts`, `path/b.tsx`
   Test first: <a case from the issue's "Tests" section, or "none">
   Check: <typecheck + which tests, or what to look at>
   Commit: <commit message>
2. …
```

Slicing rules:
- **Vertical.** Each slice is a thin path through every layer it needs (data, server, UI) and
  works on its own. Never one layer per slice.
- **Riskiest first.** The slice most likely to prove the approach wrong goes first.
- **Small.** One logical change per slice, a commit's worth. Aim for under ~100 changed lines.
- **Prepare first.** When a small refactor with no behavior change makes the work easier, it is
  slice 1.
- **Wide mechanical changes** (a rename across many files): add the new form beside the old,
  move callers over in batches, then delete the old form. Each step is its own slice.
- **Simplest thing that works.** No abstractions, options or hooks the issue does not ask for.

## 2. Build, one slice at a time

The build runs on the route's `code` model (in the runner) or on the session's model (by hand).
For each slice, in order:

1. **Test first**, when the slice names a test case: write the test, run it, and see it fail for
   the reason you expect. Test behavior through the public interface, never internals.
2. **Build** only what this slice needs.
3. **Check:** run typecheck and the tests related to this slice. Fix before moving on. Never
   skip, weaken or delete a test to make it pass.
4. **Commit** the slice with its planned message.
5. **Next slice.** When a slice shows the plan is wrong, change the remaining slices and note it
   in the report. Never start over.

While building:
- **Scope.** Change only what the issue asks. No clean-ups, renames or upgrades next to the
  change. Note them under "Noticed, not changed" instead.
- **Comments.** Add a comment only where the code cannot explain itself (a reason, an outside
  constraint, a workaround with its issue link). Keep it short and easy to understand. No
  comments that repeat the code, no banners, no commented-out code.
- **Stay green.** After every slice the project builds and the existing tests pass.
- Delete any temporary files you made.

**Parent with sub-issues:** plan all sub-issues in order on one branch; each sub-issue is one or
more slices. Run the full checks after each sub-issue.

**Feedback on a PR** (an `/agent-…` command): plan only the requested change, usually one slice.

## 3. Finish

Run the full checks once, in order (install, typecheck, tests, lint). In the runner, a failure
here counts as a fix attempt.

Report:

```markdown
## Build
Slices: 3 of 3 committed
1. `abc1234` <commit message>
2. …
Plan changes: <what changed and why>

## Noticed, not changed
- `path/file.ts`: <what, and why it is out of scope>
```

Leave out empty parts. The runner puts "Noticed, not changed" into the PR body.

Never mention cost, tokens or spend in anything posted to GitHub (issues, PRs, comments). When numbers help, use result metrics instead: checks run and their time, fix attempts, review loops, files changed, sub-issues.
