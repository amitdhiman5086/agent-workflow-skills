# Runner routine (`v2.0.0`)

Runs the `runner` skill every 15 minutes. **Each developer who wants an agent creates their own Runner routine.** `/runner setup` and `/workflow-upgrade` fill this in automatically.

## Settings

| Setting | Value |
|---|---|
| Schedule | Every 15 minutes (`*/15 * * * *`) |
| Model tier | `standard` orchestrator (`route` selects `fast`/`standard`/`deep` per phase) |
| Repository | `your-org/your-repo` |
| Needs | `runner`, `route`, `incremental-build`, `deslop`, `review-loop`, `close-out` skills; GitHub branch/PR/label access; repo runtime & dependencies |

## Prompt

```text
Run the runner skill on this repository: run close-out first, then pick and finish at most ONE job.

Settings: ~/.config/agent-workflow/<owner>/<repo>.md

Follow runner exactly: accept only issues assigned to the owner where the owner added agent-ready, or /agent-… commands from collaborators with write/maintain/admin access on the owner's open agent PRs or linked issues. Claim silently with agent-working; route via route; run incremental-build -> deslop -> single full check pass (max 3 fixes) -> review-loop (must-fix loops only, max 2). Open a concise <100-word PR and label agent-pr-ready, or open a draft PR + needs-human if stuck. End with a 1-line report.
```

## Running across agents

- **Local routine / schedule** (Claude Code, Antigravity): reads `~/.config/agent-workflow/<owner>/<repo>.md` directly.
- **Cloud routine**: install skills in-repo (`.agents/skills/` or `.claude/skills/`), inline the contents of `~/.config/agent-workflow/<owner>/<repo>.md` under `Settings:` in the prompt, and set test/UI secret variables in the runner environment (never in git).
- **CLI / Cron** (Claude CLI, Codex, OpenCode, Gemini CLI): run via `claude -p`, `codex exec`, `opencode run`, or `gemini -p` inside a dedicated repo clone or worktree.
