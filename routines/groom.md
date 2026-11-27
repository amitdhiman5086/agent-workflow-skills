# Groom routine (`v2.0.0`)

Runs the `groom` skill unattended on an hourly schedule in any coding agent or CLI runner. **Run one Groom routine per repository.**

## Settings

| Setting | Value |
|---|---|
| Schedule | Every hour (`0 * * * *`) |
| Model tier | `deep` — strongest reasoning model available (Opus high / GPT-5 high / Gemini Pro-Carbon) |
| Repository | `your-org/your-repo` |
| Needs | `groom` skill + GitHub access for issues, labels, sub-issues, and comments |

## Prompt

```text
Run the groom skill on this repository with no issue number: process at most 5 oldest open issues labelled needs-grooming (plus needs-info issues answered after Groom's question comment).
Never touch closed, agent-ready, or agent-working issues. Settle technical rulings from code yourself; use needs-info only for human product/design/access decisions. Write the compact <!-- groom:start --> context pack (<120 words), swap to agent-groomed, comment only if size/breakdown changed, and finish with a 1-line-per-issue report.
```

## Running across agents

- **App schedulers** (Claude Code Routines, Antigravity `/schedule`): paste the prompt above. Cloud runners need the skills installed in-repo (`.agents/skills/` or `.claude/skills/`) or via a shared plugin.
- **CLI / Cron / GitHub Actions** (Claude CLI, Codex, OpenCode, Gemini CLI):
  ```bash
  # Example hourly cron using your preferred coding agent CLI:
  claude -p "$(sed -n '/^```text$/,/^```$/p' routines/groom.md | sed '1d;$d')"
  # or: codex exec "..." / opencode run "..." / gemini -p "..."
  ```
