---
name: workflow-setup
description: Guided, agent-agnostic setup of the issue-to-PR workflow across Claude Code, Antigravity, Codex, OpenCode, Cursor, and Gemini CLI. Checks tools, installs skills or native plugin, creates labels, saves versioned local config, and sets up schedules. Safe to re-run. Use for /workflow-setup, "set up the workflow", "onboard me".
---

# Workflow setup

Follow `../../references/rules.md` when present: ask in small batches, inspect tools/files before asking, **never create shared repo/GitHub items without confirmation**, and **never ask for, print, or store secret values**.

Locate the workflow root two levels above this skill (`realpath`), and read `VERSION` + `manifest.json`.

## Local config file (per person & repo, never committed)
Path: `~/.config/agent-workflow/<owner>/<repo>.md`

```markdown
# Agent workflow: <owner>/<repo>

## Runner
- Workflow version: 2.0.0
- Role: <grooming | full>
- Agent: <claude | antigravity | codex | opencode | cursor | gemini>
- Owner: <github-login>
- Base branch: <branch>
- Branch prefix: <prefix/>
- Install: <cmd>
- Checks: <cmd1, cmd2>
- UI preview: <config/host:port or none>
- Screenshot branch: not allowed
- Model map: default
- Routine versions: groom 2.0.0, runner 2.0.0
```
*(For the `grooming` role, write `Workflow version`, `Role: grooming`, `Agent`, `Owner`, and `Routine versions: groom 2.0.0` so `/workflow-upgrade` tracks the repo; omit build-only keys.)*

---

## Phase 1: Preflight tools & active agent
Detect the running coding agent (`claude`, `antigravity`, `codex`, `opencode`, `cursor`, `gemini`) and verify `git --version`, `gh --version`, `gh auth status`, and project runtime (`node`, `python`, `go`, etc. if needed). Ask the user to run `gh auth login` if unauthenticated.

## Phase 2: Role & repositories
Ask:
1. **Role**: `grooming` (`capture`, `size`, `wayfinder`, `groom`, `grill-me`, `workflow-setup`, `workflow-upgrade`) or `full` (adds `route`, `runner`, `incremental-build`, `deslop`, `review-loop`, `close-out`).
2. **GitHub login**: propose `gh api user --jq .login`.
3. **Target repo(s)**: propose current repo (`gh repo view --json nameWithOwner`) and verify write access (`gh api repos/<owner>/<name> --jq .permissions.push`).

## Phase 3: Universal skill installation
Offer the cleanest option for the detected agent (paths in `manifest.json`):

| Mode | How it installs |
|---|---|
| **Native plugin / CLI** *(recommended where supported)* | Antigravity: `agy plugin install <workflow-path>` · Claude Code: `/plugin install` · Gemini CLI: `gemini extensions install <workflow-path>` · Any of 70+ agents: `npx skills add <workflow-path>` |
| **Personal symlinks** *(auto-updates on `git pull`)* | Symlink each selected `skills/<name>` into `~/.claude/skills/`, `~/.gemini/config/skills/` (Antigravity), `~/.agents/skills/` (Codex), `~/.config/opencode/skills/` (OpenCode), `~/.cursor/skills/`, or `~/.gemini/skills/` |
| **Shared in-repo** *(team + cloud routines)* | Copy into `<repo>/.agents/skills/` + `<repo>/.agents/references/rules.md` (and `<repo>/.claude/skills/` + `<repo>/.claude/references/rules.md` if Claude cloud routines run) + stamp `.workflow-version` with `VERSION`, on a branch/PR after confirmation |

Skip skills already linked to the target path and report what was added.

## Phase 4: GitHub labels (single source in `manifest.json`)
Check `gh label list --limit 300`, show missing labels from `manifest.json` (`captured`, `size:S`, `size:M`, `size:L`, `needs-grooming`, `needs-info`, `agent-groomed`, `agent-ready`, `agent-working`, `agent-pr-ready`, `needs-human`), confirm once, and create missing ones.

## Phase 5: Local config & runner settings
For `grooming`, write `~/.config/agent-workflow/<owner>/<repo>.md` with the base metadata (`Workflow version`, `Role: grooming`, `Agent`, `Owner`, `Routine versions`). For `full`, run `runner` setup steps (base branch, install/checks, branch prefix, UI preview, screenshot branch, optional `Model map` overrides) and write the full file stamped with `Workflow version` from `VERSION`.

## Phase 6: Cloud/CI environment variables (`full` role)
Read variable **names only** from `.env.example` / `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` (never values). Tell the user which variable names to set in their cloud routine or CI runner environment, and which checks/UI steps skip without them.

## Phase 7: Schedules (App Routines or CLI Cron / CI)
1. **Groom** (hourly, **1 per repo** — skip if a teammate already runs it): fill `routines/groom.md`.
2. **Runner** (every 15m, **1 per `full` developer**): fill `routines/runner.md` with `~/.config/agent-workflow/<owner>/<repo>.md` (or inline config for cloud runners).
- In apps with built-in schedulers (Claude Code routines, Antigravity `/schedule`), offer to register or print the prompt.
- For Codex, OpenCode, Gemini CLI, or headless servers, provide the ready-to-use cron / GitHub Actions command (`claude -p`, `codex exec`, `opencode run`, or `gemini -p` feeding the routine prompt).

## Phase 8: Optional smoke test & summary
Offer a quick end-to-end test on 1 tiny issue (`/capture` → `/groom` → `agent-ready` → `/runner` → `/close-out`), then print a compact checklist of everything configured.
