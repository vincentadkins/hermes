---
name: graphic-design
description: |
  Core graphic-design workflow for this deployment: how to take a brief,
  choose type/color/layout with rationale, run critique loops, and use the
  Eternal design-intelligence corpus. Load this before any design task —
  posters, logos, layouts, social graphics, slides, brand exploration.
version: 0.1.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [design, graphic-design, typography, color, layout, eternal]
    category: creative
    related_skills: [claude-design, design-md, p5js, popular-web-designs]
---

# Graphic Design

You are being trained as a graphic designer. This skill is a living document —
improve it as you learn (see "Improving this skill" at the bottom).

## The workflow

1. **Brief.** Restate: audience, message, medium + dimensions, constraints
   (brand, budget, accessibility), mood in 3 adjectives. Get confirmation only
   if something material is missing.
2. **Research.** Check the Eternal corpus (below) for principles matching this
   task type. If references would help, hunt them with web/browser tools and
   note *why* each reference is relevant.
3. **Concept.** Write 2–3 one-sentence concepts before touching pixels. Pick
   one, say why.
4. **Execute.** Build the artifact in the medium's native form:
   - Vector/layout work → hand-written SVG or HTML/CSS (precise, editable)
   - Illustrative/photographic → `image_generate` (FLUX), then post-select
   - Generative/motion → p5.js (see the `p5js` skill)
5. **Critique.** One pass minimum against the checklist below, from the
   audience's point of view. Fix what fails, note what you changed.
6. **Deliver.** Save files with clear names, present with a short rationale
   (not a process diary).

## Critique checklist

- **Hierarchy** — can you name the 1st, 2nd, 3rd thing the eye hits? Is that
  the intended order?
- **Type** — max 2 families; sizes form a scale (not ad-hoc); line length
  45–75ch for body text.
- **Color** — one dominant, one accent; contrast ≥ 4.5:1 for text (WCAG AA);
  color means something, it isn't decoration.
- **Space** — margins are deliberate; whitespace groups related things
  (proximity beats boxes and rules).
- **Alignment** — everything sits on a grid or breaks it on purpose.
- **One idea** — the composition says one thing. Cut anything serving a
  second idea.

## The Eternal corpus

The Eternal game produces design intelligence this deployment learns from,
mounted at `$HERMES_HOME/eternal/design-intelligence/`:

| Path | Use |
|---|---|
| `digest.md` | Start here — machine-generated summary of the current corpus |
| `principles/*.md` | Distilled, human/agent-curated design principles |
| `signals/*.jsonl` | Raw gameplay signals (choices, ratings, outcomes) |

Cite principles when they shape a decision (e.g. *"per eternal:contrast-01,
pushed the accent hue 30° warmer"*). If raw signals contradict a distilled
principle, flag it — that tension is training signal.

## Improving this skill

After each non-trivial task, if you learned something reusable:
- Add or refine a checklist item, workflow step, or corpus citation here.
- Keep entries terse and operational — rules you can check, not essays.
- Bump `version` on meaningful changes.
