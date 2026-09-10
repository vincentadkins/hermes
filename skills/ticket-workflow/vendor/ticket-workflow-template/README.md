# Ticket Workflow Template

An AI-assisted workflow for working through engineering tickets from setup to final report. Paste one prompt into your AI coding agent and it handles the boilerplate: pulling ticket details from your tracker, researching related documentation, writing a detailed step-by-step walkthrough, logging execution as a running journal, and producing a final report aligned to the acceptance criteria.

The workflow is tool-agnostic. It works with any capable AI coding agent, and the built-in review loops work with whatever independent reviewer you have on hand.

---

## Prerequisites

- **An AI coding agent.** Any capable one works: [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [Codex CLI](https://github.com/openai/codex), [Gemini CLI](https://github.com/google-gemini/gemini-cli), or similar.
- **A ticket tracker** you can read (Jira, Linear, GitHub Issues, etc.). If your agent cannot fetch tickets directly, you can paste the ticket contents in instead.
- **Optional: a second, independent reviewer** for the built-in review loops. This can be a second AI CLI (Codex, Gemini, a fresh agent session), or the same agent reviewing in a clean pass. It is not required, only recommended.

---

## How It Works

Tickets live in a workspace with three lifecycle folders. Each ticket gets its own folder that moves between them as the work progresses:

```
open/          captured, not started        (0-TICKET.md only)
  → in-progress/   actively being worked     (all five documents)
  → closed/        finalized and reviewed    (also searched as reference for future tickets)
```

The agent moves the folder between stages automatically at the right phase, so `in-progress/` always shows exactly what is active, and `closed/` becomes a searchable record of prior work.

Each ticket folder contains five documents that cover the full lifecycle:

| Document | Purpose |
|---|---|
| `0-TICKET.md` | Ticket definition pulled from your tracker. Written once, never modified. |
| `1-TICKET-WALKTHROUGH.md` | Detailed step-by-step execution plan. Updated if scope changes mid-execution. |
| `2-EXECUTION-LOG.md` | Append-only journal. Every action, result, failure, and retry recorded in order. |
| `SESSION-NOTE.md` | Single-page checkpoint rewritten at the end of every session. Lets a new session resume instantly without re-reading the full log. |
| `3-TICKET-REPORT.md` | Final deliverable. Every acceptance criterion addressed with cited evidence. |

The workflow runs in four phases driven by your AI agent:

```
Phase 1 - Setup      → create folder in in-progress/ (or open/ to capture only), pull ticket, fill 0-TICKET.md
Phase 2 - Planning   → move to in-progress/, research context, write walkthrough, review loop until LGTM
Phase 3 - Execution  → run steps, log every action, update walkthrough if plan changes
Phase 4 - Report     → write report, review loop, then move folder to closed/
```

Multiple sessions are supported. At the end of each session the agent writes `SESSION-NOTE.md`. The next session reads it first and continues from exactly where work stopped.

**Capture, resume, reopen.** Paste the prompt with the same ticket URL and the agent finds the existing folder in any stage: it resumes a ticket in `in-progress/`, promotes a captured ticket from `open/`, or offers to reopen one from `closed/`. Say "capture only" to just pull the ticket into `open/` for later.

---

## Quick Start

1. Open `RUNBOOK.md` in this folder.
2. Fill in the **Paths** block with your own directories (one-time setup). By default the workspace is the `all-tickets/` folder in this repo; point `WORKSPACE` elsewhere if you prefer.
3. Make sure the three lifecycle folders exist under your workspace (they already do in this repo):

   ```bash
   mkdir -p all-tickets/{open,in-progress,closed}
   ```

4. Copy the full prompt block, replace `{TICKET_URL}` with your ticket link, and paste it into a new session of your AI coding agent.

To resume a ticket that is already in progress, paste the same prompt with the same URL. The agent detects the existing folder and `SESSION-NOTE.md` and picks up from where the last session ended.

> **Note:** Working ticket folders can contain sensitive data, and this repo is public. The contents of `all-tickets/open`, `in-progress`, and `closed` are gitignored, so your real tickets are never committed. See [all-tickets/README.md](all-tickets/README.md).

---

## Folder Structure

```
ticket-workflow-template/
├── README.md               this file
├── RUNBOOK.md              the prompt to paste into your AI agent
├── template/               source files copied into every new ticket folder
│   ├── 0-TICKET.md
│   ├── 1-TICKET-WALKTHROUGH.md
│   ├── 2-EXECUTION-LOG.md
│   ├── SESSION-NOTE.md
│   └── 3-TICKET-REPORT.md
└── all-tickets/            default workspace (folder contents gitignored)
    ├── open/               captured, not started
    ├── in-progress/        actively being worked
    └── closed/             finalized and reviewed
```
