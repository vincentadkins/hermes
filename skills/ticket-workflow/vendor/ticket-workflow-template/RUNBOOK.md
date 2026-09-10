# Ticket Runbook

## How to Use

1. Fill in the **Paths** block near the top of the prompt with your own directories. You only do this once. Save your filled-in copy and reuse it.
2. Copy everything inside the prompt block below.
3. Replace `{TICKET_URL}` with your ticket link.
4. Paste into a new session of any capable AI coding agent (Claude Code, Cursor, Codex CLI, Gemini CLI, or similar).

To resume an in-progress ticket, paste the same prompt with the same URL. The agent will detect the existing folder and SESSION-NOTE.md and pick up where it left off.

To only capture a ticket for later (triage without starting work), paste the prompt and tell the agent "capture only". It fills `0-TICKET.md` under `open/` and stops.

---

## Ticket Lifecycle

Each ticket folder moves through three stages inside your workspace:

```
open/          captured, not started        (0-TICKET.md only)
  -> in-progress/   actively being worked    (all five documents)
  -> closed/        finalized and reviewed   (also searched as reference for future tickets)
```

The workflow moves the folder between these stages automatically at the right phase.

---

## Document Roles (reference)

| Document | Role | Modified when |
|---|---|---|
| 0-TICKET.md | Ticket definition pulled from your tracker. Problem statement and acceptance criteria. | Created once. Never touched again. |
| 1-TICKET-WALKTHROUGH.md | Step-by-step implementation and execution plan. | Written in Phase 2. Updated during execution when scope or approach changes. |
| 2-EXECUTION-LOG.md | Append-only journal. Every action, result, failure, retry, and decision. | Append-only throughout Phase 3. Never edited. |
| SESSION-NOTE.md | Single-page checkpoint. Where we are, what is next, active blockers, key decisions. | Rewritten at end of every session and mid-session when context gets long. |
| 3-TICKET-REPORT.md | Final deliverable. Every acceptance criterion addressed with confirmed evidence. | Written in Phase 4 after execution is complete. |

---

## Prompt

```
Ticket URL: {TICKET_URL}

## Paths (edit these once for your setup, then reuse)

WORKSPACE     = <root folder that holds your open / in-progress / closed ticket folders. Defaults to the "all-tickets" folder in this repo, e.g. ~/ticket-workflow-template/all-tickets>
TEMPLATE_DIR  = <the "template" folder from this repo, e.g. ~/ticket-workflow-template/template>
DOCS_DIRS     = <optional. Comma-separated folders of team docs to search (Confluence / Notion / wiki exports). Leave blank if none.>
REPOS_DIR     = <optional. Folder to clone support repos into, e.g. ~/projects/support-repos>

The workflow uses three lifecycle folders under WORKSPACE. Create them once if they do not exist:
  WORKSPACE/open           tickets captured but not started
  WORKSPACE/in-progress    tickets actively being worked
  WORKSPACE/closed         finalized tickets (also searched for related past work)

BEFORE ANYTHING ELSE: Extract the ticket ID (pattern [A-Z]+-[0-9]+) and look for a folder
whose name starts with that ID in WORKSPACE/open, WORKSPACE/in-progress, and WORKSPACE/closed.

- Found in WORKSPACE/in-progress with SESSION-NOTE.md filled in: resumed session. Read
  SESSION-NOTE.md immediately and jump to Phase 3 (Session start). Do not run Phase 1 or Phase 2 again.
- Found in WORKSPACE/open: captured but not started. Steps 1.1 to 1.3 are already done. Move the
  folder to WORKSPACE/in-progress, then begin at Phase 2.
- Found in WORKSPACE/closed: already finalized. Tell the human and stop, unless they confirm
  reopening it. If they do, move the folder back to WORKSPACE/in-progress and continue.
- Not found anywhere: new ticket. Start at Phase 1.

Capture-only mode: if the human says to only capture or triage this ticket, run Phase 1 to create
the folder in WORKSPACE/open, fill 0-TICKET.md, and then stop. Do not run Phase 2 or later.

---

## Ground Rules

These rules apply to everything written in this session:

1. Do not use the hyphen character as a separator or connector in any prose. Use full sentences instead.
2. Do not assume or guess any information. Every fact must come from a confirmed source: the ticket itself, a local document found during research, or official documentation found via web search. If a fact cannot be confirmed, mark it as an Open Decision requiring human input.
3. The walkthrough must be detailed enough for a reader to follow without asking questions. Every step must state the exact location (file path, UI navigation path, resource identifier, or command), the exact action to take, and what a successful result looks like.
4. If any step requires cloning a repository, clone it into REPOS_DIR. Write the exact git clone command including that path. If REPOS_DIR is blank, ask the human where to clone before proceeding.

---

## Phase 1 - Setup

### Step 1.1 - Fetch the ticket

Fetch the ticket at {TICKET_URL} from your tracker (Jira, Linear, GitHub Issues, or similar). If the tracker requires a tool or integration you do not have, ask the human to paste the ticket contents instead.

Extract the ticket ID from the URL or key. It usually matches the pattern [A-Z]+-[0-9]+, for example OMAD-1355. Use this as TICKET_ID for the rest of this session.

Also extract:
- Full title and summary
- Description (user story or problem statement)
- Acceptance criteria
- Any linked tickets, docs, or attachments mentioned in the body

### Step 1.2 - Create the ticket folder

Create the folder in WORKSPACE/in-progress (or WORKSPACE/open in capture-only mode):
  WORKSPACE/in-progress/{TICKET_ID} <ticket title>/

Copy these five template files from TEMPLATE_DIR into it, keeping the original filenames:
  TEMPLATE_DIR/0-TICKET.md             -> 0-TICKET.md
  TEMPLATE_DIR/1-TICKET-WALKTHROUGH.md -> 1-TICKET-WALKTHROUGH.md
  TEMPLATE_DIR/2-EXECUTION-LOG.md      -> 2-EXECUTION-LOG.md
  TEMPLATE_DIR/3-TICKET-REPORT.md      -> 3-TICKET-REPORT.md
  TEMPLATE_DIR/SESSION-NOTE.md         -> SESSION-NOTE.md

### Step 1.3 - Fill 0-TICKET.md

Open 0-TICKET.md. Using only confirmed content from Step 1.1:
- Set the title heading to the full ticket title
- Choose Type A (bug/data fix) or Type B (infrastructure/feature) and delete the other block
- Fill all sections using the exact wording from the ticket wherever possible
- Add cross-references to any related tickets or documents found in the ticket body
- Remove all template placeholder comments

0-TICKET.md is now final. Do not modify it again.

In capture-only mode, stop here. The ticket now sits in WORKSPACE/open ready to be started later.

---

## Phase 2 - Planning

If the ticket folder is still in WORKSPACE/open (a captured ticket you are now starting), move it to WORKSPACE/in-progress before planning:
  mv "WORKSPACE/open/{TICKET_ID} <ticket title>" "WORKSPACE/in-progress/"

### Step 2.1 - Research context

Search for documents relevant to this ticket in:
- WORKSPACE/closed and WORKSPACE/in-progress (past and active tickets on the same system or data area)
- DOCS_DIRS, if set (your local exports of team docs: Confluence, Notion, wiki)

Look for:
- Docs whose title or content matches system names, dataset names, component names, process names, or technical terms from the ticket
- Closed or in-progress tickets on the same system or data area
- Prior investigation, root cause, or design documents on the same subject

Read every relevant document. For software operations or setup steps not covered by local documents (CLI commands, cloud portal navigation, third-party tool configuration), search the internet for the authoritative documentation.

For each source, note which specific facts, file paths, resource identifiers, environment details, and process steps it confirms.

If there is nothing to search locally, rely on the ticket body plus web research.

### Step 2.2 - Write 1-TICKET-WALKTHROUGH.md

Open 1-TICKET-WALKTHROUGH.md. Write each section using only confirmed information from Step 1.1 and Step 2.1. Do not invent values, paths, identifiers, or steps.

Metadata table:
- Ticket: TICKET_ID
- Author: leave blank for the human to fill in
- Date Created: today's date
- Version: 1.0
- Status: Draft
- Link: the ticket URL

Relevant Documents table:
- Include every document from Step 2.1 that is directly relevant
- Use the local file path as the URL for local documents
- Explain in "Why It Matters" exactly which facts the document provides for this ticket

"What This Ticket Is" section:
- Write a plain-English explanation of the problem or feature
- Include specific systems, datasets, and environments using exact confirmed names
- For bug tickets, show the full data propagation chain with exact dataset names or identifiers

Scope of Work table:
- List every distinct component, dataset, or environment that will be touched
- Use exact names and identifiers confirmed from the ticket or documents

Open Decisions section:
- Add a row for every fact required by the walkthrough that could not be confirmed from any source
- Remove this section entirely if there are no open decisions

Steps 1 through N:
- Write one step per distinct action the executor must take
- Each step must include:
    a. Exact location: file path, portal navigation path, resource identifier, command, or URL confirmed from research
    b. Exact action: what to click, what to run, what to type, what to modify
    c. Expected result: what success looks like, including expected row counts, output values, or UI state
- For any step involving a query, include the full query text
- For any step involving a code change, include the exact code block
- For any step involving a portal or UI, include the full navigation path from the login screen
- For any step requiring a repository clone, use REPOS_DIR as the destination and write the exact git clone command
- If a step cannot be written concretely because information is missing, add an Open Decision row instead

Acceptance Criteria Mapping table:
- One row for every criterion in 0-TICKET.md
- Map each to the specific step number that satisfies it

Done Criteria checklist:
- Each item must correspond to a concrete action or verification step in the walkthrough

Remove all template placeholder comments.

### Step 2.3 - Walkthrough review loop

Have an independent reviewer check the walkthrough against the checklist below. Use whichever option you have available:
- A second AI CLI run non-interactively (for example codex, gemini, or a fresh claude session), OR
- A fresh, clean session of the same agent, OR
- If none of the above is available, do the review yourself in a separate pass with fresh eyes.

Point the reviewer at:
  WORKSPACE/in-progress/{TICKET_ID} <ticket title>/1-TICKET-WALKTHROUGH.md

Review instruction:

  "You are a senior engineer reviewing a ticket walkthrough. Read the file and check for all of the following:
  1. Unfilled template placeholders such as [Doc Name], [URL], or [YYYY-MM-DD]
  2. Steps that are still generic boilerplate and not specific to this ticket
  3. Steps missing an exact location, exact action, or expected result
  4. Missing rows in the Acceptance Criteria Mapping table - every criterion in 0-TICKET.md must have exactly one row
  5. Open Decisions that could have been answered from the ticket body or linked documents
  6. Done Criteria items that have no corresponding step in the walkthrough
  7. Any fact that appears assumed or guessed rather than sourced from a confirmed document or the ticket

  For each issue found output:
    ISSUE [number]: [section or step name] - [specific problem]

  If no issues are found output exactly: LGTM"

Example invocation with the Codex CLI (substitute your own reviewer if different):
  codex --full-auto "<the review instruction above, with the file path filled in>"

If any ISSUE lines appear:
- Fix each issue in 1-TICKET-WALKTHROUGH.md. If caused by missing confirmed information, add an Open Decision row instead of guessing.
- Run the review again.
- Repeat until the output is exactly LGTM.

The walkthrough is now the baseline plan. Proceed to Phase 3.

---

## Phase 3 - Execution

### Session start

If resuming (SESSION-NOTE.md has content):
- Read SESSION-NOTE.md first. Do not open any other document until you have read it.
- Go to the step and log entry it references.
- Execute the Next Action it specifies. Do not re-read the full walkthrough or log from the beginning.

If starting fresh (first session on this ticket):
- Initialize SESSION-NOTE.md now with: Last Updated = now, Walkthrough Version = 1.0, Last Log Entry = "None yet", Overall Status = "In Progress", Current step = Step 1, Last action = "Walkthrough finalized", Next Action = the first concrete action in walkthrough Step 1, all other fields = "None".

### Execution rules

2-EXECUTION-LOG.md is an append-only journal. Never edit a past entry. Every action, every failure, every retry, and every decision is a new numbered entry.

For each action taken:

1. Carry out the action described in the walkthrough step.
2. Immediately add a new entry to 2-EXECUTION-LOG.md: next sequential number, current timestamp, step reference, Action (what was done), Result (exact output verbatim), Outcome (one of: Success / Failed / Partial / Blocked), Decision / Next (what happens because of this result).
3. On Success: move to the next step.
4. On Failed or Partial: do not edit the failed entry. The retry is a new entry with the same step reference and "(Retry N)" in the title.
5. On Blocked: record who or what is blocking and the resolution path. Do not proceed past this step until resolved. When resolved, add a new entry for the resolution before continuing.
6. If the walkthrough plan turns out to be wrong or incomplete: add a log entry describing what was discovered, update 1-TICKET-WALKTHROUGH.md, increment its version number, and continue from the corrected step.
7. If scope changes: add a log entry with the new scope, update 1-TICKET-WALKTHROUGH.md to reflect it.

### Session checkpoints

Rewrite SESSION-NOTE.md completely when:
- You are ending the session (always do this before stopping, without exception)
- Context in the current session has grown long enough that earlier decisions are becoming hard to track

When rewriting:
- Last Updated = now, Last Log Entry = most recent entry number
- Current step = step you are on or the next to execute
- Last action = what was just completed
- Next Action = the single most specific next thing to do, with exact paths or commands
- Open Blockers = active blockers only, remove resolved ones
- Key Decisions = only non-obvious decisions that affect remaining work
- Must Not Forget = only time-sensitive or easy-to-miss constraints

Continue until every walkthrough step has at least one log entry with Outcome = Success and every item in the Done Criteria checklist can be checked off with a reference to the confirming entry.

---

## Phase 4 - Report

### Step 4.1 - Write 3-TICKET-REPORT.md

Open 3-TICKET-REPORT.md. Fill each section using confirmed results from 2-EXECUTION-LOG.md:

- Metadata: Ticket, Date Completed (today), Version 1.0, Status Draft, Link
- Summary: 2 to 4 sentences - what was done, what changed, final outcome
- Acceptance Criteria Outcomes: one row per criterion from 0-TICKET.md, marked Pass/Fail/Partial, with cited evidence (log entry number, row count, query result)
- What Changed: every file, dataset, config, or resource modified or created, with what changed and why
- Verification Results: full query text and exact output for each primary verification check
- Scope Deviations: anything that differed from the original ticket scope, or "None"
- Walkthrough Changes Made During Execution: any updates made to 1-TICKET-WALKTHROUGH.md, or "None"
- Follow-Up Items: deferred or out-of-scope work, with priority and ticket ID where possible

### Step 4.2 - Report review loop

Have an independent reviewer check the report against the checklist below, using the same options as Step 2.3 (a second AI CLI, a fresh session, or a clean self-review pass).

Point the reviewer at:
  - WORKSPACE/in-progress/{TICKET_ID} <ticket title>/0-TICKET.md
  - WORKSPACE/in-progress/{TICKET_ID} <ticket title>/3-TICKET-REPORT.md

Review instruction:

  "You are a senior engineer reviewing a final ticket report. Read both files and check for:
  1. Any acceptance criterion in 0-TICKET.md missing from the Acceptance Criteria Outcomes table
  2. Any criterion marked Pass or Fail without cited evidence
  3. Unfilled template placeholders in the report
  4. A Summary that does not match the outcomes table
  5. Scope deviations not explained in the Scope Deviations table
  6. Follow-Up items referencing work required by acceptance criteria that was not delivered

  For each issue found output:
    ISSUE [number]: [section name] - [specific problem]

  If no issues are found output exactly: LGTM"

Example invocation with the Codex CLI (substitute your own reviewer if different):
  codex --full-auto "<the review instruction above, with the file paths filled in>"

If any ISSUE lines appear:
- Fix each issue in 3-TICKET-REPORT.md. If the issue reveals incomplete execution, return to Phase 3 to finish the missing work before updating the report.
- Run the review again.
- Repeat until the output is exactly LGTM.

### Step 4.3 - Final handoff

Report back with:
- Full path to the ticket folder
- Overall outcome (all criteria passed, partial, or failed with reason)
- Any Open Decisions or Follow-Up items still requiring human action

### Step 4.4 - Close the ticket

Only after the report review loop returns LGTM and the handoff is delivered, move the ticket folder from WORKSPACE/in-progress to WORKSPACE/closed:
  mv "WORKSPACE/in-progress/{TICKET_ID} <ticket title>" "WORKSPACE/closed/"

Do not move a ticket to closed while any acceptance criterion is still Fail or Partial without a recorded Follow-Up item. Set the report Status to Final. The closed folder is now reference material: Step 2.1 of future tickets searches it for related prior work.
```
