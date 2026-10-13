---
name: workflow-setup
description: Guided, question-by-question setup of the team's issue-to-PR workflow (capture, size, groom, route, runner, review-loop, close-out) for one person and one or more repos. Checks tools, installs the skills, creates labels, configures the runner, explains secrets, creates or prints the routines, and offers a test run. Safe to re-run; it only fills gaps. Use for /workflow-setup, "set up the workflow", "install the workflow skills", "onboard me to the agent workflow".
---

# Workflow setup

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

Install `capture`, `size`, `groom` for everyone; add `route`, `runner`, `review-loop`,
`close-out` for the "full" role. Skip any that already exist, and say which.

```bash
ln -s "<workflow>/skills/<name>" ~/.claude/skills/<name>
```

## Phase 4: Labels (per repo)

List which of these exist (`gh label list --limit 200`) and which are missing:

`captured`, `size:S`, `size:M`, `size:L`, `needs-grooming`, `needs-info`, `agent-groomed`,
`agent-ready`, `agent-working`, `agent-pr-ready`, `needs-human`

Ask once, then create the missing ones (colors and descriptions are in the skills; any sensible
color is fine).

## Phase 5: Runner settings (full role, per repo)

Run the `runner` skill's setup, or ask the same questions here:
1. **Base branch.** Suggest the one most merged PRs target:
   `gh pr list --state merged --limit 100 --json baseRefName --jq 'group_by(.baseRefName)|map({b:.[0].baseRefName,n:length})'`.
   No preference: the repo's default branch.
2. **Install and checks.** Read `package.json` scripts and `CLAUDE.md`; propose install,
   typecheck, tests and lint (only those that exist). Confirm.
3. **Branch prefix.** Default: the user's first name, lowercase, e.g. `amit/`.

## Phase 6: Models

Show the defaults and ask if they want changes:

| Job | Default |
|---|---|
| Groom routine | Opus 5.5, high effort |
| Runner routine (orchestrates) | Sonnet 5.5, high effort |
| Plan / code / review | Chosen per issue by Groom's `Route:` line (route skill has the fallback table) |

In another tool, map to its strongest reasoning model and its standard coding model.

## Phase 7: Secrets for the cloud (full role)

The checks and the UI review may need environment variables (database URL, API keys).
- List the **names** from `.env.example` (or `.env` names only, never values) and `CLAUDE.md`.
- Ask which ones the checks really need.
- Tell the user to add them in the app's environment settings for the routine. Never write
  values into files, issues, PRs or this chat.
- Say plainly which checks or UI reviews will be skipped without them.

## Phase 8: Routines

Two routines, created in the agentic app (not on the laptop):

| Routine | Who | Schedule | Prompt |
|---|---|---|---|
| Groom | **One person per repo** (two would groom the same issues twice) | Hourly | `routines/groom.md` |
| Runner | **Every "full" person**, their own | Every 15 minutes | `routines/runner.md` |

1. Ask: is someone already running the Groom routine for this repo? If yes, skip it.
2. Check the skills can reach the cloud: they must be in the repo (`.claude/skills/`) or a shared
   plugin, not only on this laptop. If not, explain and offer Phase 3's "In the repo" option.
3. Fill in the prompts with the answers from Phases 2, 5 and 6.
4. If the app lets you create scheduled routines, offer to create them. Otherwise show the filled
   prompts and the settings to paste.

## Phase 9: Test run (optional, recommended)

Offer a guided test on one small, harmless issue:

`/capture` (runs `/size`) → `/groom <n>` → user adds `agent-ready` and assigns themselves →
`/runner <n>` → user reviews and merges → `/close-out <n>`

Stop at any step the user wants to skip.

## Phase 10: Summary

Show the checklist: tools ✓, skills installed (where), labels (created or existing), runner
settings, models, secrets the user still has to add, routines (created or prompts given), test
result, and anything left to do.
