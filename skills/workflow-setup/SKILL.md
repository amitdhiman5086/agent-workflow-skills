---
name: workflow-setup
description: Guided, question-by-question setup of the team's issue-to-PR workflow (capture, size, groom, route, runner, review-loop, close-out, plus grill-me, incremental-build and deslop) for one person and one or more repos. Checks tools, installs the skills, creates missing labels, configures the runner, explains secrets, creates or prints the routines, and offers a test run. Safe to re-run; it only fills gaps. Use for /workflow-setup, "set up the workflow", "install the workflow skills", "onboard me to the agent workflow".
---

# Workflow setup

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Walk the user through a complete setup by asking questions and doing the steps for them.

**How to run this guide**
- Go phase by phase. Ask one small group of questions at a time and wait for the answers.
- Check before you ask: if you can find an answer yourself (a command, a file), propose it and
  ask the user to confirm.
- **Never create anything other people can see without a yes:** labels, files in a shared repo,
  PRs, routines.
- **Never ask for, print or store secret values.** Only variable names.
- Re-running is normal. Detect what is already done, say so, and skip it.
- Keep a checklist as you go and show it at the end.

Locate the workflow folder first: it is two levels above this file
(`skills/workflow-setup/SKILL.md`). Resolve symlinks (`realpath`) if the skill was linked. It
contains `README.md`, `skills/` and `routines/`. Read `README.md` for the flow and labels.

**Local settings file.** Each person keeps one file per repo on their own computer, outside the
repo, so nothing is committed: `~/.config/agent-workflow/<owner>/<repo>.md` (`<owner>/<repo>` from
`gh repo view --json nameWithOwner`). It holds the runner's settings. Phase 5 writes it:

```markdown
# Agent workflow: <owner>/<repo>

## Runner
- Owner: <github-login>
- Base branch: develop
- Branch prefix: amit/
- Install: npm ci
- Checks: npm run typecheck, npm test, npm run lint
- UI preview: <dev-server config name>, <app host and port>
- Screenshot branch: not allowed
```

Create the folder if needed. On a re-run, update the file in place and keep what the user set.

---

## Phase 1: Tools

Check and report each one:

| Check | Command | If missing |
|---|---|---|
| Agent tool | Which app you are running in (Claude Code, Codex, other) | Note it; the skill folder differs per tool |
| git | `git --version` | Tell the user how to install it |
| GitHub CLI | `gh --version` | Suggest installing it, or use the app's GitHub connector instead |
| GitHub login | `gh auth status` | Ask the user to run `gh auth login` themselves |
| Node | `node --version` | Only needed for repos that use it |

Do not install software without asking.

## Phase 2: Who and what

Ask:
1. **Your role.** "Grooming only" (capture, size, groom: for product or leads) or "full"
   (everything, including the agent that builds PRs).
2. **GitHub login.** Propose `gh api user --jq .login` and confirm.
3. **Repos.** Which repos (`owner/name`)? For each, propose the local clone from the current
   folder or ask for its path. Check write access:
   `gh api repos/<owner>/<name> --jq .permissions.push`.

## Phase 3: Install the skills

Ask where:

| Option | What it means |
|---|---|
| **Personal, linked** (recommended) | Link each skill folder into your tool's personal skills folder (Claude Code: `~/.claude/skills/`). Updating the workflow folder updates the skills |
| Personal, copied | Same place, copies. No automatic updates |
| In the repo | Copy into `<repo>/.claude/skills/` so everyone in the repo gets them and cloud routines can see them. This changes a shared repo: confirm, then do it on a branch with a PR |

Install `capture`, `size`, `groom`, `grill-me` for everyone; add `route`, `runner`,
`incremental-build`, `deslop`, `review-loop`, `close-out` for the "full" role. Skip any that already exist, and say which.

```bash
ln -s "<workflow>/skills/<name>" ~/.claude/skills/<name>
```

## Phase 4: Labels (per repo)

The workflow uses the same label names in every repo. This table is the one place their colors
and descriptions live; the skills create a missing label from it.

| Label | Color | Description |
|---|---|---|
| `captured` | `c5def5` | Captured, waiting for size and groom |
| `size:S` | `c2e0c6` | Under 2 hours, 1-3 files |
| `size:M` | `fef2c0` | Up to 1 day, under 10 files |
| `size:L` | `f9d0c4` | More than 1 day; split into sub-issues |
| `needs-grooming` | `bfd4f2` | Sized, waiting for the Groom routine |
| `needs-info` | `d93f0b` | Blocked on a human decision |
| `agent-groomed` | `0e8a16` | Groomed by agent, waiting for human |
| `agent-ready` | `1d76db` | Approved for the agent to build |
| `agent-working` | `fbca04` | Agent is building this |
| `agent-pr-ready` | `5319e7` | Agent PR open, review requested |
| `needs-human` | `b60205` | Agent stuck, or its PR closed without merging |

List which exist (`gh label list --limit 300`) and which are missing. Ask once, then create the
missing ones: `gh label create "<label>" --color <color> --description "<description>"`.

## Phase 5: Runner settings (full role, per repo)

Run the `runner` skill's setup (`/runner setup`). It asks for the base branch, install and
checks, branch prefix, UI preview and screenshot branch, and saves them in the local file's
`## Runner` section. Labels are already done in Phase 4.

## Phase 6: Models

Show the defaults and ask if they want changes:

| Job | Default |
|---|---|
| Groom routine | Opus 5.5, high effort |
| Runner routine (orchestrates) | Sonnet 5.5, high effort |
| Plan | Opus 5.5, xhigh effort, or no plan for a clear S (Groom's `Route:` line) |
| Code / review | Chosen per issue by Groom's `Route:` line (route skill has the fallback table) |

In another tool, map to its strongest reasoning model and its standard coding model.

## Phase 7: Secrets for the cloud (full role)

The checks and the UI review may need environment variables (database URL, API keys).
- List the **names** from `.env.example` (or `.env` names only, never values) and `CLAUDE.md`.
- Ask which ones the checks really need.
- Tell the user to add them in the app's environment settings for the routine. Never write
  values into files, issues, PRs or this chat.
- Say plainly which checks or UI reviews will be skipped without them.

## Phase 8: Routines

Two routines, created as scheduled tasks in the agentic app:

| Routine | Who | Schedule | Prompt |
|---|---|---|---|
| Groom | **One person per repo** (two would groom the same issues twice) | Hourly | `routines/groom.md` |
| Runner | **Every "full" person**, their own | Every 15 minutes | `routines/runner.md` |

1. Ask: is someone already running the Groom routine for this repo? If yes, skip it.
2. Check the routine can read the skills and the local file. A local routine (runs on this
   computer) can. A cloud routine cannot: the skills must be in the repo (`.claude/skills/`) or a
   shared plugin (Phase 3's "In the repo"), and the local file's content goes into its prompt.
3. Fill in the prompts with the local file's path (Phase 5) and the models (Phase 6).
4. If the app lets you create scheduled routines, offer to create them. Otherwise show the filled
   prompts and the settings to paste.

## Phase 9: Test run (optional, recommended)

Offer a guided test on one small, harmless issue:

`/capture` (runs `/size`) → `/groom <n>` → user adds `agent-ready` and assigns themselves →
`/runner <n>` → user reviews and merges → `/close-out <n>`

Stop at any step the user wants to skip.

## Phase 10: Summary

Show the checklist: tools ✓, skills installed (where), local file path, labels (created or existing),
runner settings, models, secrets the user still has to add, routines (created or prompts given), test
result, and anything left to do.
