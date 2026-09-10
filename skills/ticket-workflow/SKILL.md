---
name: ticket-workflow
description: |
  Four-phase workflow for carrying an engineering ticket from tracker to
  signed-off report: pull the ticket, research context, write a step-by-step
  walkthrough, log execution as an append-only journal, and produce a final
  report mapped to the acceptance criteria. Load this whenever a task arrives
  as a ticket, an issue link, or a multi-session piece of work that needs a
  paper trail — not for one-off design briefs.
version: 0.1.0
author: franklioxygen (upstream template), wrapped for this deployment
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [tickets, workflow, planning, execution-log, handoff, documentation]
    category: engineering
    related_skills: [graphic-design]
---

# Ticket Workflow

A brief tells you what to make. A ticket tells you what to make, what counts as
done, and who has to be convinced afterwards. This skill is for the second kind.

The full procedure lives in the vendored upstream runbook. This file is the
binding: it fills in the paths, names the reviewer you actually have, and says
what to do with a ticket once it closes.

**Read the runbook before starting:**
`vendor/ticket-workflow-template/RUNBOOK.md`

Everything under `vendor/` is upstream's tree, unmodified. Fixes and
improvements belong in this file, not in there — see `vendor/VENDOR.md`.

## Paths for this deployment

Substitute these wherever the runbook's Paths block asks for them:

| Runbook variable | Value here |
|---|---|
| `WORKSPACE` | `$HERMES_HOME/tickets` |
| `TEMPLATE_DIR` | `$HERMES_HOME/skills/ticket-workflow/vendor/ticket-workflow-template/template` |
| `DOCS_DIRS` | `$HERMES_HOME/eternal/design-intelligence` (only when the ticket is design work; otherwise blank) |
| `REPOS_DIR` | `$HERMES_HOME/repos` |

`scripts/deploy.sh` creates `$HERMES_HOME/tickets/{open,in-progress,closed}` and
`$HERMES_HOME/repos`. If you are running somewhere those do not exist, create
them before Phase 1:

```bash
mkdir -p "$HERMES_HOME"/tickets/{open,in-progress,closed} "$HERMES_HOME/repos"
```

Ignore the runbook's default of `all-tickets/` inside the vendored folder. That
directory is upstream's example workspace and is not where your tickets go —
real ticket folders hold internal identifiers and query text, so they live in
runtime state under `$HERMES_HOME`, which is gitignored, alongside `studio/`
and `memories/`.

## The shape of it

Each ticket is a folder that moves through three stages, carrying five
documents:

```
tickets/open/          captured, not started       0-TICKET.md only
  → tickets/in-progress/   actively being worked   all five documents
  → tickets/closed/        finalized and reviewed  searched by future tickets
```

| Document | What it is for |
|---|---|
| `0-TICKET.md` | The ticket as the tracker states it. Written once in Phase 1, never touched again. |
| `1-TICKET-WALKTHROUGH.md` | The plan. Every step names an exact location, an exact action, and what success looks like. |
| `2-EXECUTION-LOG.md` | Append-only journal. Failures and retries are new entries, never edits. |
| `SESSION-NOTE.md` | One page, rewritten at the end of every session, so the next session resumes without re-reading the log. |
| `3-TICKET-REPORT.md` | The deliverable. Every acceptance criterion answered with cited evidence. |

Four phases: Setup, Planning, Execution, Report. The runbook has the step
detail; do not paraphrase it from memory.

## Your reviewer

The runbook's two review loops (Step 2.3 on the walkthrough, Step 4.2 on the
report) assume you might have a second AI CLI on hand. In this deployment you
generally do not. Use the third option it offers: a separate clean pass with
fresh eyes, reading only the file under review and the checklist, without
leaning on what you remember writing.

Run that pass honestly. It is the same discipline as the critique loop in
`graphic-design` — a review that never returns an ISSUE line is a review that
did not happen. Iterate until the pass genuinely returns `LGTM`.

## Ground rules worth repeating

The runbook states these; they are the ones that get dropped first.

- **Never guess a fact.** Every value, path, identifier, and step comes from the
  ticket, a document you actually read, or official documentation you actually
  found. Anything you cannot confirm becomes an Open Decision row for the human,
  not a plausible-looking placeholder.
- **The log is append-only.** A failed step stays in the record. The retry is a
  new numbered entry.
- **Write `SESSION-NOTE.md` before you stop.** Every time, without exception.
  It is the only thing standing between a paused ticket and a cold restart.
- **No hyphens as connectors in ticket prose.** An upstream house rule that
  applies to what you write inside the five ticket documents. Write full
  sentences instead. It does not apply to this skill file or to code.

## After a ticket closes

`tickets/closed/` is a corpus, the same way `eternal/design-intelligence/` is a
corpus. Phase 2 research of every future ticket searches it, so a closed ticket
keeps paying out.

Per your learning duties in `SOUL.md`, when a ticket teaches you something
reusable — a research move that surfaced the right document, a class of Open
Decision that keeps recurring, a report structure a reviewer accepted without
pushback — fold it into this file and record the judgment in memory. Leave
`vendor/` alone.

## Improving this skill

Additions belong under the headings above. When you change how the workflow
runs, say so in one line at the point of change rather than appending a
changelog. If a change is really an upstream fix, note it in `vendor/VENDOR.md`
so the next sync knows the divergence is deliberate.
