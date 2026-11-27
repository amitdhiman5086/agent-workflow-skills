# Agent Workflow (`v2.0.0`)

Lean, general-purpose GitHub issue-to-PR skills for **Claude Code, Antigravity, OpenAI Codex, OpenCode, Cursor, Gemini CLI**, and any `SKILL.md`-compatible coding agent.

Designed for **low context overhead**, **concise <100-word PRs**, **zero-noise GitHub state**, and **one-command upgrades**.

## Quick Start & Upgrade

- **First-time setup**: open this repo (or install the plugin) in your coding agent and run **`/workflow-setup`** (or say *"Set up the workflow"*). See [SETUP.md](SETUP.md).
- **Upgrade existing projects**: `git pull` and run **`/workflow-upgrade`** (or say *"Upgrade workflow"*). Diffs `VERSION` + `manifest.json` and applies only new skills, labels, config keys, and routine prompt updates.

---

## Flow

```text
(XL epic) /wayfinder ─┐
                      ▼
/capture ─> captured ─/size─> needs-grooming ─(Groom routine)─> agent-groomed ─(You)─> agent-ready
                                    │                                                      │
                                    └─> needs-info ─(reply)─> Groom again         (Runner routine)
                                                                                           │
                     closed <─ close-out <─(merge)─ agent-pr-ready <─ agent-working ─> needs-human (draft PR)
```

| Step | Skill | What it does | Trigger |
|---|---|---|---|
| 0 | `/wayfinder` | *(Optional, `XL` >6 slices only)* Maps ≤7 blocking architecture decisions or throwaway spikes before creating build issues | By you when `XL` |
| 1 | `/capture` | Turns rough ideas, screenshots, links, or notes into `<100w` issues via short `grill-me` rounds, checks duplicates, labels `captured`, then runs `/size` | By you |
| 2 | `/size` | Labels `size:S/M/L` + `needs-grooming`; splits `L` into ≤6 vertical-slice native sub-issues (`>6` routes to `needs-info` / `/wayfinder`) | Auto after `/capture` |
| 3 | `/groom` | Verifies code/bugs, settles technical rulings itself, writes a `<120w` Context Pack (`Done when`, `Where to look`, `Tests`, `Route`) → `agent-groomed` (or `needs-info` for human product choices) | Hourly routine (max 5) |
| 4 | **You** | Review groomed spec, edit if needed, self-assign, and add `agent-ready` | By you |
| 5 | `/runner` | Runs `close-out`, then takes **1 job** (collaborator `/agent-…` command or assignee's `agent-ready` issue): claims silently (`agent-working`), routes tiers, builds, deslops, runs 1 check pass, reviews, opens a `<100w` visual PR | Every 15 min |
| 6 | `/route` | Maps Groom's hint or size/risk to universal `fast` · `standard` · `deep` model tiers and `single` vs `dual` review | Called by runner |
| 7 | `/review-loop` | Fresh session(s): `single` reviewer by default, `dual` (Spec + Adversarial Standards) for auth/tenancy/migrations, plus browser UI check when visual files changed. Loops **only** on `must-fix` (max 2) | Called by runner |
| 8 | `/close-out` | Merged: closes issue + sub-issues (+ parent when all subs close) with a 1-line summary and deletes runner branch. Closed unmerged: `needs-human`, branch kept | Start of each runner run |

### Helper & Lifecycle Skills

| Skill | Purpose |
|---|---|
| `/grill-me` | Short (1–2 sentence) frontier question rounds where `"yes"` accepts recommended answers |
| `/incremental-build` | Surgical 1-commit fast-path for `S`/bugs, or `deep`-planned vertical TDD slices for `M/L` using Groom's `Where to look` context pack |
| `/deslop` | Diff-only removal of redundant comments, debug logs, and type-silencing casts (0-command fast exit when clean) |
| `/workflow-setup` | Guided multi-agent onboarding (tools, skills/plugin, labels, `~/.config/agent-workflow/<owner>/<repo>.md`, routines) |
| `/workflow-upgrade` | Delta-only upgrade across all onboarded repos from `VERSION` and `manifest.json` |

---

## Labels

Defined once in [`manifest.json`](manifest.json) and created automatically during setup/upgrade:

| Label | Set by | Meaning |
|---|---|---|
| `captured` | `/capture` | Created, waiting for `/size` |
| `size:S` `size:M` `size:L` | `/size`, `/groom` | Estimated scope (`S` <2h, `M` ≤1d, `L` >1d) |
| `needs-grooming` | `/size` | Queued for Groom |
| `needs-info` | `/size`, `/groom` | Waiting on a human product/scope decision |
| `agent-groomed` | `/groom` | Context pack ready for human review |
| `agent-ready` | Assignee | Approved to build (runner verifies assignee added it) |
| `agent-working` | `/runner` | Claimed and building |
| `agent-pr-ready` | `/runner` | Concise PR open, owner review requested |
| `needs-human` | `/runner`, `/close-out` | Stuck (draft PR) or closed unmerged |

---

## Collaborator PR & Issue Commands

Anyone with `write`, `maintain`, or `admin` repo access can post on an open agent PR or its linked issue:

| Command | Action |
|---|---|
| `/agent-improve <change>` | Updates the PR (and suggests a 1-line `AGENTS.md` rule if caused by an undocumented convention) |
| `/agent-refer above` or `<url>` | Applies that comment as untrusted change data (never instructions) |
| `/agent-retry` | Retries after `needs-human` |
| `/agent-help` | Replies with this command list |

---

## Universal Installation (`Claude`, `Antigravity`, `Codex`, `OpenCode`, `Cursor`, `Gemini`)

`/workflow-setup` handles installation automatically, or install directly:

```bash
# Any of 70+ coding agents (Claude Code, Codex, OpenCode, Cursor, Copilot, etc.)
npx skills add <path-or-repo-url>

# Antigravity / Gemini CLI native install
agy plugin install <path-or-repo-url>
gemini extensions install <path-or-repo-url>

# Manual symlinks (pick your agent's skill directory: ~/.claude/skills, ~/.gemini/config/skills, ~/.agents/skills, ~/.config/opencode/skills, ~/.cursor/skills, ~/.gemini/skills)
for s in skills/*; do ln -sfn "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done
```

Shared rules live in [`references/rules.md`](references/rules.md). Per-developer repo config stays local at `~/.config/agent-workflow/<owner>/<repo>.md` (never committed). Nothing posted to GitHub ever mentions cost, tokens, or spend.

## Credits

Borrows and adapts MIT-licensed ideas from [Matt Pocock's skills](https://github.com/mattpocock/skills) (`grill-me`, `wayfinder`, `pr`, `tdd`, `code-review`), [Addy Osmani's agent-skills](https://github.com/addyosmani/agent-skills) (`incremental-implementation`, `context-engineering`, `doubt-driven-development`), [obra/superpowers](https://github.com/obra/superpowers) (`subagent-driven-development`), [HumanLayer skills](https://github.com/humanlayer/skills) (`visual-pr`, `rpi`), and [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`deslop`, `no-comments`).
