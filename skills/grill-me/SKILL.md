---
name: grill-me
description: Interview the user about a plan, idea, issue or design until you both understand it the same way. Asks in rounds of numbered questions, each with a recommended answer that "yes" accepts, and looks up facts itself instead of asking. Used by /capture to agree on an issue before drafting it; also by hand for any plan. Use for /grill-me, "grill me", "are we on the same page", "stress-test this plan".
argument-hint: <plan, idea or issue>
---

# Grill me

Based on Matt Pocock's `grill-me` and `grilling` skills (MIT).

## Writing rules

Apply to every issue, comment, PR body, review and report this skill writes.

- Write to the point: facts, decisions, next step. No greetings, filler, hedging, recaps or praise.
- Short sentences. Bullets over paragraphs. One idea per bullet.
- Leave out empty sections and anything the reader already sees in the issue, diff or labels.
- Keep exact names: files, labels, commands, error text.
- Aim for: comments 1–3 lines, issue bodies under 150 words, PR bodies under 200 words. Go longer only when the work needs it.

Ask questions until you and the user understand the plan the same way. Build, create or post
nothing while grilling.

Input: $ARGUMENTS, or the plan in the conversation.

## 1. Map the decisions

Treat the plan as a tree of decisions: each decision opens the ones that depend on it. The
**frontier** is every open decision whose earlier decisions are settled: the questions you can
ask now without guessing an answer you have not heard yet.

## 2. Ask the frontier, one round at a time

Ask every frontier question in one message, then wait for the answers.

```
❓ **Q1** - **<short title>**: <the question, with the options when there are some>

➡️ <your recommended answer>

---

❓ **Q2** - **<short title>**: …

➡️ …
```

- Word each question so that "yes" accepts your recommendation.
- Always recommend. Add a one-line reason when the choice is not obvious.
- Keep numbering across rounds (round 2 starts after the last number of round 1), so answers
  stay easy to reference.
- A question that depends on another open question waits for a later round.

## 3. Facts are yours, decisions are theirs

- Never ask what you can look up: code, files, issues, docs, settings, tool output. Look it up
  yourself. For a wide search, use a sub-agent, and ask the rest of the frontier meanwhile.
- Put every decision to the user: product, scope, priority, trade-offs, anything that is a
  matter of choice.

## 4. Next round

Apply the answers. "yes" accepts every recommendation in the round; "Q3: b" picks an option;
free text replaces the recommendation. A question left unanswered is asked again, unless the
user says to take your recommendation. Then recompute the frontier and ask the next round.

## 5. Done

The grilling ends when the frontier is empty: every branch visited, nothing assumed in silence.
Show the agreed result as a short summary (decisions, open risks) and ask the user to confirm
it. Act on it only after that yes.
