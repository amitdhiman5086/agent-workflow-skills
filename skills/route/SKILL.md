---
name: route
description: Decide which model plans, codes and reviews a groomed GitHub issue, from the "Route" line Groom wrote in the issue's Agent hints, with a size-based fallback. Used by the runner before it starts building. Use for /route <issue>, "which model should build this".
argument-hint: <issue number>
---

# Route

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

## Labels

Label names in this skill are roles. The repo may use its own label for a role.
- Read the `## Labels` section of the local settings file
  `~/.config/agent-workflow/<owner>/<repo>.md` (`<owner>/<repo>` from
  `gh repo view --json nameWithOwner`).
- Use the repo's label for each role everywhere: `gh` commands, searches and comments. A role
  missing from the file uses its role name.
- No file yet: never create a label, since one with the same meaning may exist. Run the label
  matching in the `workflow-setup` skill (Phase 4) first.

Pick the model for each phase of building an issue. The decision comes from Groom (step 3), and a
human may have edited it while grooming. Route only reads it and fills gaps.

## 1. Read the Route line

In the issue body, inside the `<!-- groom:start -->` section, under "Agent hints", find:

```
- Route: plan <none|sonnet|opus> · code <sonnet|opus> · review <sonnet|opus>
```

Example: `- Route: plan opus · code sonnet · review sonnet`

## 2. Fill gaps from the size

If the line is missing, or a phase is missing, use the issue's `size:*` label:

| Size | plan | code | review |
|---|---|---|---|
| S | none | sonnet | sonnet |
| M | sonnet | sonnet | sonnet |
| L, or a parent with sub-issues | opus | sonnet | sonnet |

Review always runs, at high effort. No size label and no Route line: treat as M.

## 3. Map names to models

| Name | Model | Effort |
|---|---|---|
| sonnet | Claude Sonnet 5.5 (`claude-sonnet-5-5`) | high |
| opus | Claude Opus 5.5 (`claude-opus-5-5`) | high for plan, medium for code |

In another tool, use its nearest equivalents: its strongest reasoning model for `opus`, its
standard coding model for `sonnet`.

## 4. Output

Return the plan in one line, and explain it in one sentence:

```
Route #<n>: plan opus · code sonnet · review sonnet (from Groom's hints)
```

## How the runner applies it

Each phase runs in its own sub-session with that model, when the tool supports choosing a model
per sub-agent (Claude Code: the agent tool's `model` option). The review sub-session must start
fresh, with no memory of the coding session. If the tool cannot choose models per sub-session,
run every phase on the session's model and say so in the PR.
