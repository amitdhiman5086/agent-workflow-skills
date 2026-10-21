# Runner routine

Runs the `runner` skill on a schedule inside your agentic app. Each person who wants an agent
creates their own runner routine. `/runner setup` fills in this prompt for you.

## Settings

| Setting | Value |
|---|---|
| Schedule | Every 15 minutes |
| Model | Claude Sonnet 5.5, high effort (it orchestrates; `route` picks the models per phase) |
| Repository | e.g. `your-org/your-repo` |
| Needs | The `runner`, `route`, `incremental-build`, `deslop`, `review-loop` and `close-out` skills; GitHub access that can push branches, open PRs, edit labels and comment; Node and the repo's install command in the environment |

## Prompt

```
Run the runner skill on this repository: take ONE job and finish it.

Settings: ~/.config/agent-workflow/<owner>/<repo>.md

Start with the close-out skill for merged or closed agent PRs. Then follow the skill exactly: only issues assigned to the owner where the owner added agent-ready,
or /agent-… commands from anyone with write access to the repo, posted on its open agent PRs or on the issues they are built for; claim with agent-working first; route models
with the route skill; at most 3 check-fix attempts and 2 review loops; on success open the PR,
request the owner's review and label agent-pr-ready; when stuck open a draft PR and label
needs-human. End with the one-line report.
```

## Before the first run

- A local routine (runs on your computer) reads the skills and the settings file where they are.
- A cloud routine cannot see your computer. Put the skills in a shared place (team plugin or the
  repo's `.claude/skills/`) and paste the settings file's content into the prompt in place of its
  path. Its environment needs the repo's dependencies installed, and any secrets the checks need
  (for example `.env` values) set as environment variables in the app, never in the repo.
- Try one issue by hand first: `/runner <number>`.
