---
name: route
description: Pick agent-agnostic model tiers (fast, standard, deep) and review depth (single vs dual) for planning, coding, and reviewing a GitHub issue from Groom's Route hint or size/type fallback. Works across Claude Code, Antigravity, Codex, OpenCode, Cursor, and Gemini CLI. Use for /route <issue>.
argument-hint: "<issue number>"
---

# Route

Follow `../../references/rules.md` when present.

Selects the model tier and review mode per phase from Groom's `<!-- groom:start -->` hints, with smart size/risk fallbacks.

## 1. Read Groom's hints
In the issue's `## Agent hints`, look for:
```text
- Type: <bug | feature | refactor>
- Route: plan <none|deep> · code <standard|deep> · review <single|dual> (<standard|deep>)
```
Legacy normalization: `opus` → `deep`, `sonnet` → `standard`, `plan sonnet` → `plan deep`, bare `review standard` → `review single (standard)`, bare `review deep` → `review dual (deep)`.

## 2. Fallback table (when `Route` or a field is missing)

| Issue shape | `plan` | `code` | `review` |
|---|---|---|---|
| `size:S`, or single-root-cause `Type: bug` | `none` | `standard` | `single (standard)` |
| `size:M` or `size:L` (normal feature/refactor) | `deep` | `standard` | `single (standard)` |
| Any issue touching auth, security, tenancy, DB migrations, or public contracts | `deep` | `standard` (or `deep`) | `dual (deep)` |

Missing size and `Route`: treat as `size:M`.

## 3. Universal model tier mapping
Use `Model map:` in `~/.config/agent-workflow/<owner>/<repo>.md` when configured; otherwise map to the running coding agent's native models:

| Tier | Role | Claude Code | Antigravity | Codex | OpenCode / Cursor / Gemini CLI |
|---|---|---|---|---|---|
| `fast` | Read-only file localization | Haiku | `flash` / `flash_lite` | Codex mini / fast | Fastest configured coding model |
| `standard` | Coding, surgical patches, single review | Sonnet (high) | `inherit` / Pro | Codex / GPT-5 (medium-high) | Default coding model |
| `deep` | Architecture plan (`xhigh`), complex code, adversarial `dual` review | Opus (`xhigh` plan / `high` review) | Highest reasoning model (`pro` / Carbon) | GPT-5 / o-series (`high` / `xhigh`) | Strongest reasoning model |

## 4. Sub-session & inline execution rules
- **Sub-agent capable hosts**: run `plan`, `code`, and `review` in isolated sub-sessions pinned to their routed tier so reviewers never inherit coding chat history.
- **Single-session hosts** (or tools without per-subagent model switching): run phases sequentially on the session's active model, writing `.agents/artifacts/<branch>/plan.md` between phases to keep context clean.

## 5. Output
1 line only:
```text
Route #<n> (<type>): plan <none|deep> · code <standard|deep> · review <single|dual> (<standard|deep>)
```
