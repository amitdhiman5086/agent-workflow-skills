# Shared Workflow Rules

Every skill in this workflow follows these rules.

## 1. Concise Writing (GitHub & Chat)
- Facts, decisions, next step only. No greetings, filler, hedging, recaps, or praise.
- Short bullets over prose. Omit empty sections and anything already visible in labels or diffs.
- Keep exact identifiers (`path/file.ts:42`, labels, commands, error strings).
- Hard caps: comments 1–2 lines, issue drafts <100 words, groomed blocks <120 words, PR bodies <100 words.
- Between tool calls, narrate at most one short line.
- **Never mention cost, tokens, or spend in anything posted to GitHub** (issues, PRs, comments). Use engineering result metrics when needed (checks passed, files changed, sub-issues).

## 2. Universal Agent Conventions
- **Project instructions**: Read `AGENTS.md` first; fall back to `CLAUDE.md` or `GEMINI.md` (plus docs they link).
- **GitHub access**: Prefer `gh` CLI when authenticated; otherwise use the host agent's GitHub MCP/connector tools.
- **Sub-sessions & models**: When the host agent supports sub-agents with model selection, use the tier from `route` (`fast`, `standard`, `deep`). Otherwise run phases sequentially in the active session using `.agents/artifacts/<branch>/` files as clean phase handoffs.
- **Scratch artifacts**: Store ephemeral plans, context packs, and check logs under `.agents/artifacts/<branch-slug>/` and add `.agents/artifacts/` to `.git/info/exclude` so scratch files are never committed.

## 3. Rulings, Not Stalls
- Never pause a run for questions answerable from code, tests, git history, or project conventions.
- Settle technical ambiguities yourself and record a 1-line `Ruling: <choice> — <why>` for the reviewer.
- Stop for a human **only** on: product/design choices code cannot answer, destructive or security-sensitive actions, missing external credentials, or a contradictory spec.
