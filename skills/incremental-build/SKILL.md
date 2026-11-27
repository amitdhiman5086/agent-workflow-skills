---
name: incremental-build
description: Build a GitHub issue or task with minimal context waste. Uses a surgical fast-path for small changes and bugs, or a deep vertical-slice plan for M/L features with test-first commits and strict scope. Use for /incremental-build <issue or task>, "build step by step".
argument-hint: "<issue number or task>"
---

# Incremental build

Based on Addy Osmani's `incremental-implementation`, pstack's `principle-sequence-verifiable-units`, Matt Pocock's `tdd`, and `obra/superpowers` execution rules (MIT). Follow `../../references/rules.md` when present: max 1-line narration between tool calls, and **never mention cost, tokens, or spend on GitHub**.

## 1. Load Context Pack (do not re-search the repo cold)
- Ensure `.agents/artifacts/` is in `.git/info/exclude`, and create `.agents/artifacts/<branch-slug>/`.
- Read the issue body, `<!-- groom:start -->` section (`Done when`, `Where to look`, `Tests`, `Out of scope`, `Agent hints`), and `AGENTS.md` (fallback `CLAUDE.md`, `GEMINI.md`).
- Open the exact files cited in `Where to look` first. Only run a repository search when `Where to look` is absent or incomplete (prefer a `fast` read-only explorer returning `path:line` only).

## 2. Choose execution path

### Path A: Surgical / Bug Fast-Path (`plan none`, or standalone non-high-risk `size:S` / single-root-cause `Type: bug` when `route` was not run)
Skip slice planning overhead and execute in 1 slice:
1. **Reproduce** (for bugs): run the failing test, script, or trace the exact failing mechanism.
2. **Test first**: when `Tests` specifies a case, add the regression test and confirm it fails for the expected reason.
3. **Patch narrowest layer**: fix or build at the responsible boundary without drive-by edits.
4. **Verify & commit**: run typecheck + related tests, then commit once.

### Path B: Sliced Build (`plan deep` on `M` / `L` / parent with sub-issues)
1. **Plan once (`deep` tier, read-only)**: write `.agents/artifacts/<branch-slug>/plan.md` with thin vertical slices (<100 lines each; prep refactor first, then riskiest slice first; wide renames split as add-beside → migrate callers → remove old):
   ```markdown
   Goal: <1 line>
   1. <slice title> — files: `path/a.ts` · test: <named case | none> · check: <cmd> · commit: `<msg>`
   ```
2. **Build slice by slice (`code` tier)**:
   - Write named failing test first (public interface only) → implement only this slice → run typecheck + slice tests → commit.
   - If a slice disproves the plan, update remaining slices in `plan.md` and continue (never restart from zero).
   - For a parent issue, build sub-issues in order on one branch and run targeted slice checks after each sub-issue (full checks run once at Finish).

## 3. Strict coding discipline (prevents `deslop` & review loops)
- **Scope**: touch only what `Done when` requires. No drive-by refactors or extra features.
- **Zero slop at write time**: no comments that restate code, no banners, no `console.log`/debug prints, no `any`/`as unknown as` type-silencing casts. Add a 1-line comment only for non-obvious external constraints or issue-linked workarounds.
- **Rulings, not stalls**: resolve minor technical ambiguities yourself and append `Ruling: <choice> — <why>` to `.agents/artifacts/<branch-slug>/plan.md`. Stop only for destructive actions, missing secrets, or a broken spec.
- Remove temporary files outside `.agents/artifacts/`.

## 4. Finish
- **Inside `runner`**: stop after slice checks pass (`runner` runs `deslop` and the single full check pass next).
- **Standalone by hand**: run full checks once (install, typecheck, tests, lint).

Return a compact summary (<60 words): commits made, 1–3 bullets or a tiny structural `diff` sketch for the PR body, and any `Ruling:` lines.
