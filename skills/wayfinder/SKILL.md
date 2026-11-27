---
name: wayfinder
description: Shape an XL or high-uncertainty effort (>6 sub-issues or open architecture choices) as a compact map of at most 7 decisions or throwaway prototypes before creating build issues. Use for /wayfinder, "map decisions for this epic", or when /size flags an XL issue.
argument-hint: "<epic idea or issue number>"
---

# Wayfinder

Adapted from Matt Pocock's `wayfinder` concept (`aihero.dev/skills-wayfinder`), hardened against over-planning and grilling fatigue. Follow `../../references/rules.md` when present: **never mention cost, tokens, or spend on GitHub**.

Use **only** for `XL` efforts (>6 slices) or work blocked on coupled architectural unknowns. For normal `S/M/L` work, skip straight to `/capture` → `/size` → `/groom`.

## Hard Guardrails
1. **Decisions only, never production code**: Never build or ship production changes inside a `wayfinder` session. Throwaway spike code lives only under `.agents/artifacts/wayfinder-<slug>/` (gitignored).
2. **Bounded map (max 7 nodes)**: Cap the decision graph at 7 open decisions/spikes. Scope to one clear milestone, never "build all of V1".
3. **1–2 sentence questions**: Never write multi-paragraph prompts. State each decision in 1–2 sentences with a `➡️` recommendation and why it unlocks downstream slices.

## 1. Chart the decision frontier
Read `AGENTS.md` (fallback `CLAUDE.md`, `GEMINI.md`) and the target code paths. List the **3–7 blocking decisions** whose answers determine the architecture, data model, or UX contract:

```markdown
<!-- wayfinder:map -->
## Destination
<1 sentence defining the bounded outcome>

## Decisions
- [ ] **D1** (frontier): <decision> — *blocks D3*
- [ ] **D2** (spike): <unknown to test in a throwaway prototype>
- [ ] **D3**: <decision> — *depends on D1*
```

If invoked on an existing `XL` GitHub issue, post/update this `<!-- wayfinder:map -->` block on that issue; otherwise hold it in chat until settled.

## 2. Settle frontier nodes
- **Question node**: Ask the current unblocked frontier using `grill-me` format (max 1–2 sentences per item, `"yes"` accepts `➡️` recommendations).
- **Spike node**: Build the smallest throwaway check in `.agents/artifacts/wayfinder-<slug>/` to falsify or prove the technical question, report the concrete result in 2 lines, and present the choice to the user (never silently pick product UX yourself).

Mark settled nodes `[x] **D1**: <chosen option>` and recompute the frontier until all nodes are settled.

## 3. Collapse into bounded build issues
Once all decisions are `[x]`:
1. Summarize the settled architecture in ≤8 bullets.
2. Propose **1–3 bounded parent issues** (each ≤6 vertical slices).
3. On user confirmation, create them via `/capture` (skipping repeat grilling) → `/size` → `needs-grooming`, and close/retire the planning issue if separate. Delete `.agents/artifacts/wayfinder-<slug>/`.
