---
name: grill-me
description: Align with the user on an idea, plan, or spec through short frontier rounds of numbered questions, each with a recommended answer that "yes" accepts. Looks up code/repo facts itself instead of asking. Use for /grill-me, "grill me", "stress-test this plan".
argument-hint: "<plan, idea, or issue>"
---

# Grill me

Based on Matt Pocock's `grill-me` / `grilling` skills (MIT), tightened against prompt fatigue. Follow `../../references/rules.md` when present.

Build, edit, or post nothing while grilling.

## 1. Facts are yours, decisions are theirs
- Look up everything the repo, docs (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`), git history, or issue tracker can answer before asking. Use a `fast` read-only sub-agent for broad searches when available.
- Ask the user **only** product, scope, trade-off, or design choices.

## 2. Ask the current frontier (1–2 sentences max per question)
Model decisions as a dependency tree; ask only unblocked frontier questions in one batch:

```markdown
❓ **Q1 — <short title>**: <1–2 sentence question + options if applicable>
➡️ <recommended answer + brief why when non-obvious>
```

- Word every question so `"yes"` accepts all `➡️` recommendations in the round.
- Keep numbering continuous across rounds (`Q1`, `Q2`, then `Q3`...).
- Apply answers (`yes`, `Q2: b`, or free text), recompute the frontier, and repeat until no open decision remains.

## 3. Confirm
Show a compact bullet summary of agreed decisions and remaining risks (under 100 words), and wait for confirmation before acting.
