# [TICKET-ID] Execution Log

| Field | Value |
|---|---|
| **Ticket** | [TICKET-ID] |
| **Executor** | [Name] |
| **Walkthrough Version** | [e.g. 1.0] |
| **Started** | [YYYY-MM-DD] |
| **Last Updated** | [YYYY-MM-DD] |
| **Status** | Not Started / In Progress / Blocked / Complete |

---

## How to Use This Log

This is an append-only journal. The rules are:

- Add a new entry for every action taken, in chronological order.
- Never edit or delete a past entry. If something was wrong, the correction is a new entry.
- If a step fails and you retry, the retry is a new entry, not an update to the failed one.
- Paste exact output: error text verbatim, exact row counts, exact command output, exact UI state.
- Every blocked state, every wrong turn, and every scope surprise belongs here. This is the record future readers use to understand what actually happened, not just what the plan said.

---

## Entries

---

### Entry 001 | YYYY-MM-DD HH:MM | Step [N] - [Step Title from Walkthrough]

**Action:**
[What was attempted. Exact command run, query executed, portal action taken, or file modified.]

**Result:**
[Exact output. Paste error text verbatim. Include row counts, timestamps, command stdout/stderr, or UI state observed. Do not summarize — paste the real output.]

**Outcome:** Success / Failed / Blocked / Partial

**Decision / Next:**
[What happens next because of this result. If retrying, what changes. If blocked, who is unblocking it and how. If scope changed, what the new scope is. If continuing, which step comes next.]

---

### Entry 002 | YYYY-MM-DD HH:MM | Step [N] - [Step Title] (Retry 1)

**Action:**

**Result:**

**Outcome:** Success / Failed / Blocked / Partial

**Decision / Next:**

---

<!-- Add new entries below this line. Do not edit entries above. -->

---

## Done Criteria

[Copy the Done Criteria checklist from 1-TICKET-WALKTHROUGH.md here. Check off each item only after a log entry confirms it is complete. Link the entry number next to each checked item.]

- [ ] [Item from walkthrough Done Criteria]
- [ ] [Item from walkthrough Done Criteria]
- [ ] [Item from walkthrough Done Criteria]
