# Agent instructions

This repository holds the team's general-purpose GitHub issue-to-PR workflow: skills (`skills/`), shared rules (`references/rules.md`), routine prompts (`routines/`), versioned manifest (`VERSION`, `manifest.json`), multi-agent plugin manifests, and docs (`README.md`, `SETUP.md`).

- **Setup / Onboarding**: follow `skills/workflow-setup/SKILL.md`.
- **Upgrading existing repos**: follow `skills/workflow-upgrade/SKILL.md`.
- **Editing skills**:
  - Keep standard `SKILL.md` YAML frontmatter (`name` and `description`) and agent-agnostic instructions (`AGENTS.md` with `CLAUDE.md`/`GEMINI.md` fallback; `fast`/`standard`/`deep` model tiers).
  - Keep outputs concise and human-readable; **nothing posted to GitHub may mention cost, tokens, or spend**.
  - Keep `VERSION`, `manifest.json`, plugin manifests, `README.md`, and `scripts/validate-workflow.sh` in sync with any skill or label change.
