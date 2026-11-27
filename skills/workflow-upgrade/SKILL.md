---
name: workflow-upgrade
description: One-command delta upgrade across already-onboarded repositories after pulling new workflow changes. Diffs installed Workflow version against VERSION/manifest.json, links or syncs new/updated skills, prunes deprecated ones, adds missing labels, backfills new config keys, and refreshes changed routine prompts. Use for /workflow-upgrade, "upgrade workflow", "update workflow".
argument-hint: "[owner/repo] (empty = all onboarded repos)"
---

# Workflow upgrade

Follow `../../references/rules.md` when present: show a concise delta before changing shared repos or GitHub, never overwrite user customizations, and never read/print secret values.

Makes `git pull` → `"Upgrade workflow"` effortless across every project already using this workflow.

## 1. Locate workflow root & latest version
1. Resolve symlinks (`realpath`) from this skill to locate the workflow repository root.
2. Check `git -C <workflow-root> status -sb` and `git -C <workflow-root> fetch --quiet` (when online):
   - If behind upstream and the working tree is clean, ask whether to run `git -C <workflow-root> pull --ff-only` first.
3. Read `<workflow-root>/VERSION` and `<workflow-root>/manifest.json`.

## 2. Discover onboarded targets (including v1 installs)
Collect targets (filtered by `$ARGUMENTS` if given):
- Personal configs: `~/.config/agent-workflow/*/*.md` (read `Workflow version`, `Role`, `Agent`, and `Routine versions`; missing `Workflow version` = `1.0.0`).
- Existing personal/plugin installs (even without a config file yet): scan `~/.claude/skills`, `~/.gemini/config/skills`, `~/.gemini/config/plugins/agent-workflow`, `~/.agents/skills`, `~/.config/opencode/skills`, `~/.cursor/skills`, `~/.gemini/skills` for existing workflow skills (`capture`, `groom`, `runner`).
- Current workspace (in-repo installs): `<repo>/.agents/skills/` or `<repo>/.claude/skills/` (missing `.workflow-version` = `1.0.0`).

If nothing is installed anywhere yet, route to `/workflow-setup` instead.

## 3. Compute delta only (never re-ask settled settings)
Compare each target's installed version against `VERSION` and `manifest.json`:
1. **Skills delta**:
   - Determine user role (`Role` in local config; fallback `full` if `runner` is installed or `Base branch` exists, else `grooming`).
   - Add missing skills from `coreSkills` (+ `fullSkills` for `full`) in the configured agent's skill directory, **refresh copied `SKILL.md` files (or re-run plugin install) when not symlinked**, and remove any skills listed in `deprecatedSkills`.
   - If skills were copied into `<repo>/.agents/skills/` or `<repo>/.claude/skills/` and `.workflow-version != VERSION`, sync changed `SKILL.md` files + `references/rules.md`.
2. **Labels delta** (per repo): diff `gh label list --repo <owner>/<repo> --limit 300 --json name` against `manifest.json`'s `labels`.
3. **Config delta**: check `~/.config/agent-workflow/<owner>/<repo>.md` against `manifest.json`'s `configKeys` (only base keys for `Role: grooming`). Auto-fill safe defaults (`Workflow version: <VERSION>`, inferred `Role`, detected `Agent`, `Model map: default`, `Routine versions` from `manifest.json`), and ask the user **only** if a newly introduced key requires a project-specific choice.
4. **Routines delta**: compare `Routine versions` in the local config against `manifest.json`'s `routines.*.version`.

## 4. Preview & apply
Show a compact summary of changes (1–2 lines per category).
- Local symlinks & local config updates: apply once confirmed (or directly when strictly additive version stamps/symlinks).
- Shared changes (creating new GitHub labels, or opening a sync branch/PR for in-repo copied skills): ask for an explicit **yes** first.
- Stamp `Workflow version: <VERSION>` and updated `Routine versions` in `~/.config/agent-workflow/<owner>/<repo>.md` (and `.workflow-version` if in-repo).
- If `routines/groom.md` or `routines/runner.md` changed version, print only the updated routine prompt(s) to paste or update the scheduled task.

## 5. Report
1 line per repo: `<owner>/<repo>: <oldVersion> → <VERSION> (skills: +<added>/-<removed>, labels: +<n>, routines: <up-to-date | updated>)`.
