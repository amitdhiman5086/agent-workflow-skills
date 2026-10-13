# Runner routine

Runs the `runner` skill on a schedule inside your agentic app. Each person who wants an agent
creates their own runner routine. `/runner setup` fills in this prompt for you.

## Settings

| Setting | Value |
|---|---|
| Schedule | Every 15 minutes |
| Model | Claude Sonnet 5.5, high effort (it orchestrates; `route` picks the models per phase) |
| Repository | e.g. `your-org/your-repo` |
| Needs | The `runner`, `route`, `review-loop` and `close-out` skills; GitHub access that can push branches, open PRs, edit labels and comment; Node and the repo's install command in the environment |

## Prompt

```
Run the runner skill on this repository: take ONE job and finish it.

Owner: <github-login>
Base branch: <branch> (an issue's "Base:" line overrides it)
Branch prefix: <prefix>/
Install: <install command>
Checks, in order: <typecheck command>, <test command>, <lint command>
UI preview: <dev-server config name>, <app host and port> (leave out when the repo has no UI)
Screenshot branch: <allowed | not allowed>

Start with the close-out skill for merged or closed agent PRs. Then follow the skill exactly: only issues assigned to the owner where the owner added agent-ready,
or /agent-… commands from the owner on its PRs; claim with agent-working first; route models
with the route skill; at most 3 check-fix attempts and 2 review loops; on success open the PR,
request the owner's review and label agent-pr-ready; when stuck open a draft PR and label
needs-human. End with the one-line report.
```

## Before the first run

- The skills must reach the routine through a shared place (team plugin or the repo's
  `.claude/skills/`); a cloud routine cannot see `~/.claude/skills` on your laptop.
- The cloud environment needs the repo's dependencies installed, and any secrets the checks
  need (for example `.env` values) set as environment variables in the app, never in the repo.
- Try one issue by hand first: `/runner <number>`.
