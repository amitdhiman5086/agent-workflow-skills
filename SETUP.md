# Setup & Upgrades

Works in **Claude Code, Antigravity, OpenAI Codex, OpenCode, Cursor, Gemini CLI**, and any `SKILL.md`-compatible agent.

## First-Time Setup (~5–10 min)

Open this repository in your coding agent and say:

> Set up the workflow.

*(Or run `/workflow-setup` if already installed.)*

Setup detects your coding agent, installs the skills (native plugin, `npx skills`, personal symlinks, or in-repo `.agents/skills/`), creates missing GitHub labels from [`manifest.json`](manifest.json), writes your private config at `~/.config/agent-workflow/<owner>/<repo>.md` (never committed), and outputs your scheduled routine or CLI cron commands.

## Upgrading Existing Projects (~30 sec)

Whenever this workflow repo gets new skills or improvements:

1. Pull the latest changes (`git pull`).
2. Say **"Upgrade workflow"** (or run `/workflow-upgrade`).

`/workflow-upgrade` compares each project's `Workflow version` against [`VERSION`](VERSION) + [`manifest.json`](manifest.json) and applies **only the delta**: new/deprecated skills, missing labels, new config keys, and updated routine prompts.

## For Agents

Follow `skills/workflow-setup/SKILL.md` for onboarding and `skills/workflow-upgrade/SKILL.md` for upgrades. Confirm before creating anything visible to teammates, and never ask for or print secret values.
