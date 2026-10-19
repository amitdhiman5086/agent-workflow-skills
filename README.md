# Workflow skills

Shared skills for the team's issue-to-PR workflow. They use the standard `SKILL.md` format, so
they work in Claude Code and other agentic tools that read skills.

## Setup

Open this folder in your agentic app and say **"Set up the workflow"** (or run `/workflow-setup`).
The agent asks you questions and does the setup. See [SETUP.md](SETUP.md).

## Flow

```
/capture ─> captured ─/size─> needs-grooming ─Groom routine─> agent-groomed ─you─> agent-ready
                                                   │                                        │
                                                   └─> needs-info ─(answer)─> Groom again    Runner routine
                                                                                            │
                                       close-out <─(you merge)─ agent-pr-ready <─ agent-working ─> needs-human (draft PR)
```

| Step | Skill | What it does | Runs | Status |
|---|---|---|---|---|
| 1 | `/capture` | Idea, screenshots, links or notes → agrees on each with you in `grill-me` rounds → issue(s) labelled `captured`, then runs `/size` | By you | Ready |
| 2 | `/size` | `size:S/M/L` + `needs-grooming`; L becomes a parent with up to 6 ordered sub-issues, each a vertical slice | Automatic after capture | Ready |
| 3 | `/groom` | Checks it is not already built and confirms bugs, re-checks size and sub-issues, decides technical questions itself, writes Done when / where to look / tests / out of scope / agent hints → `agent-groomed`, or `needs-info` with numbered questions only for real decisions | Routine, hourly, max 5 | Ready |
| 4 | You | Review, groom further if you want, add `agent-ready` and assign to yourself | By you | — |
| 5 | `/runner` | `setup` once per repo (base branch, checks, prefix, labels, UI preview, saved in your local file) and writes the routine prompt; each run builds ONE job (your `agent-ready` issue or an `/agent-…` command on its PR) with `/incremental-build`, then `/deslop`, then `/review-loop` | Routine, every 15 min | Ready |
| 6 | `/route` | Reads Groom's `Route:` line (size fallback): plan `none` or Opus at xhigh effort, and which model codes and reviews | Called by runner | Ready |
| 7 | `/review-loop` | Two fresh reviewers in parallel: Spec (Done when, scope, bugs) and Standards (rules, leftovers, smells), plus the UI in a browser; findings rest on what they ran or read; every finding goes back to the coder; max 2 loops; result in the PR body | Called by runner | Ready |
| 8 | `/close-out` | Merged: closes issue + sub-issues (and the parent when all subs are done), deletes the runner's branch, posts a metrics summary. Closed unmerged: `needs-human`, branch kept | Start of every runner run | Ready |

### Helper skills

Called by the steps above, and useful on their own.

| Skill | What it does | Used by |
|---|---|---|
| `/grill-me` | Rounds of numbered questions, each with a recommended answer that "yes" accepts, until you agree on a plan | `/capture`; `/groom`'s question format |
| `/incremental-build` | Deep plan on Opus at xhigh effort as vertical slices, then one slice at a time: failing test first, build, check, commit | Runner |
| `/deslop` | Removes comments that repeat the code, debug code and other clutter from a change; behavior unchanged | Runner, before review |

## Labels

| Label | Set by | Meaning |
|---|---|---|
| `captured` | /capture | New, not sized yet |
| `size:S` `size:M` `size:L` | /size, /groom | Estimated size |
| `needs-grooming` | /size | Waiting for the Groom routine |
| `needs-info` | /groom | Blocked on a human decision; answer in a comment |
| `agent-groomed` | /groom | Groomed by the agent, waiting for you |
| `agent-ready` | You (the assignee) | Approved for the agent to build |
| `agent-working` | Runner | Being built |
| `agent-pr-ready` | Runner | PR open, your review requested |
| `needs-human` | Runner, close-out | Stuck (draft PR), or PR closed without merging. Reply `/agent-retry` or `/agent-improve …` |

The names are the same in every repo. Setup creates the missing ones; their colors and
descriptions live in one place, `workflow-setup` Phase 4.

The runner's settings live in a local file per person and repo, never committed:
`~/.config/agent-workflow/<owner>/<repo>.md`.

No skill mentions cost, tokens or spend on GitHub; they report result metrics (checks, fix attempts, review loops, files changed) instead.

## Install by hand (the setup does this for you)

```bash
ln -s "$PWD/skills/capture" ~/.claude/skills/capture
ln -s "$PWD/skills/size" ~/.claude/skills/size
ln -s "$PWD/skills/groom" ~/.claude/skills/groom
ln -s "$PWD/skills/route" ~/.claude/skills/route
ln -s "$PWD/skills/runner" ~/.claude/skills/runner
ln -s "$PWD/skills/review-loop" ~/.claude/skills/review-loop
ln -s "$PWD/skills/close-out" ~/.claude/skills/close-out
ln -s "$PWD/skills/grill-me" ~/.claude/skills/grill-me
ln -s "$PWD/skills/incremental-build" ~/.claude/skills/incremental-build
ln -s "$PWD/skills/deslop" ~/.claude/skills/deslop
ln -s "$PWD/skills/workflow-setup" ~/.claude/skills/workflow-setup
```

Or copy `skills/*` into a project's `.claude/skills/` to share them with everyone in that repo.
Routines (scheduled runs in the app) are described in `routines/`.

Needs: `gh` logged in (`gh auth status`), or the app's GitHub connector.

## Credits

Some skills borrow ideas from these MIT-licensed collections:
- [Matt Pocock's skills](https://github.com/mattpocock/skills): `grill-me`, `grilling`,
  `to-tickets`, `triage`, `tdd`, `code-review`.
- [Addy Osmani's agent-skills](https://github.com/addyosmani/agent-skills):
  `incremental-implementation`.
- [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan (Claude port by
  Michael Denyer): `deslop`, `no-comments`, `principle-sequence-verifiable-units`,
  `principle-prove-it-works`.
