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
| 1 | `/capture` | Idea, screenshots, links or notes → issue(s) labelled `captured`, then runs `/size` | By you | Ready |
| 2 | `/size` | `size:S/M/L` + `needs-grooming`; L becomes a parent with up to 6 ordered sub-issues | Automatic after capture | Ready |
| 3 | `/groom` | Re-checks size and sub-issues, writes Done when / where to look / tests / out of scope / agent hints → `agent-groomed`, or `needs-info` with a question | Routine, hourly, max 5 | Ready |
| 4 | You | Review, groom further if you want, add `agent-ready` and assign to yourself | By you | — |
| 5 | `/runner` | `setup` once per repo (base branch, checks, prefix, labels, routine prompt); each run builds ONE job: your `agent-ready` issue or an `/agent-…` command on its PR | Routine, every 15 min | Ready |
| 6 | `/route` | Reads Groom's `Route:` line (size fallback): which model plans, codes, reviews | Called by runner | Ready |
| 7 | `/review-loop` | Fresh review session: judges what to check (Done when, scope, bugs, rules, leftovers, UI in a browser); every finding goes back to the coder; max 2 loops; result in the PR body | Called by runner | Ready |
| 8 | `/close-out` | Merged: closes issue + sub-issues (and the parent when all subs are done), deletes the runner's branch, posts a metrics summary. Closed unmerged: `needs-human`, branch kept | Start of every runner run | Ready |

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

Each skill creates its labels the first time it needs them.

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
ln -s "$PWD/skills/workflow-setup" ~/.claude/skills/workflow-setup
```

Or copy `skills/*` into a project's `.claude/skills/` to share them with everyone in that repo.
Routines (scheduled runs in the app) are described in `routines/`.

Needs: `gh` logged in (`gh auth status`), or the app's GitHub connector.
