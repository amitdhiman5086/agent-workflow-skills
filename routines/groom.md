# Groom routine

Runs the `groom` skill on a schedule inside your agentic app (Claude, Codex or similar).

## Settings

| Setting | Value |
|---|---|
| Schedule | Every hour |
| Model | Most capable available, high effort (Claude: Opus 5.5, high) |
| Repository | The repo to groom, e.g. `your-org/your-repo` |
| Needs | The `groom` skill available to the routine, and GitHub access that can edit issues, labels and comments |

## Prompt

Paste this as the routine's prompt:

```
Run the groom skill on this repository with no issue number: groom the open issues labelled
needs-grooming, and the needs-info issues that got an answer, at most 5 this run.
Labels: ~/.config/agent-workflow/<owner>/<repo>.md
Follow the skill exactly: never touch agent-ready, agent-working or closed issues; ask for a
human decision only with the needs-info label and a comment; explain every size or sub-issue
change in a comment. End with the one-line-per-issue report.
```

## Before the first run

- A local routine (runs on your computer) reads the skill and the label mapping where they are.
- A cloud routine cannot see your computer. The skill must reach it through a shared place (the
  team plugin or the repo's `.claude/skills/`), and the settings file's `## Labels` section goes
  into the prompt in place of its path.
- Try the skill once by hand on one issue (`/groom <number>`) and read the result.
