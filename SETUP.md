# Setup

Your agent sets this up with you. It asks questions, checks your tools and does the steps.

## For people

Open this folder in your agentic app (Claude Code, Codex or similar) and say:

> Set up the workflow.

If the `workflow-setup` skill is already installed, you can also run `/workflow-setup` from any
project.

It takes about 10 minutes and covers: tools, your role and repos, installing the skills, GitHub
labels, runner settings, models, secrets for the cloud, the two routines, and an optional test
run. You can run it again any time; it only fills what is missing.

## For agents

Follow `skills/workflow-setup/SKILL.md` step by step. Ask the user before creating anything
others can see, and never ask for or print secret values.
