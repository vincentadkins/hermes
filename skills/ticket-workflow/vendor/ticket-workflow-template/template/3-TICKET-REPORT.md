# [TICKET-ID] Report: [Ticket Title]

| Field | Value |
|---|---|
| **Ticket** | [TICKET-ID] |
| **Author** | [Name] |
| **Date Completed** | [YYYY-MM-DD] |
| **Version** | 1.0 |
| **Status** | Draft / Final |
| **Ticket Link** | [URL] |

---

## Summary

[2 to 4 sentences. What was done, what changed, and the final outcome. Written for someone who has not read the walkthrough or log.]

---

## Acceptance Criteria Outcomes

[One row per criterion from 0-TICKET.md. Every criterion must appear here.]

| Criterion | Result | Evidence |
|---|---|---|
| [Criterion verbatim from 0-TICKET.md] | Pass / Fail / Partial | [Query result, row count, screenshot reference, or step in log that confirms it] |
| [Criterion verbatim from 0-TICKET.md] | Pass / Fail / Partial | |

---

## What Changed

[List every artifact that was modified or created as part of this ticket.]

| Artifact | Type | Change Description |
|---|---|---|
| [File path, dataset name, config file, infrastructure resource] | Code / Config / Infrastructure / Data | [What was added, removed, or modified and why] |

---

## Verification Results

[Key query outputs and test results that prove the work is correct. Include the exact result for each primary verification check from the walkthrough.]

### [Check Name, e.g. Primary invalid-record count]

```sql
[Query that was run]
```

**Result:** [Exact output, e.g. 0 rows. Pre-fix baseline was 11 rows.]

### [Check Name]

**Result:** [Exact output]

---

## Scope Deviations

[Anything that differed from the original ticket or walkthrough scope. If nothing deviated, write "None."]

| Original Scope | Actual Scope | Reason |
|---|---|---|
| [e.g. 9 affected records] | [e.g. 11 affected records] | [e.g. 2 additional records appeared between investigation and fix] |

---

## Walkthrough Changes Made During Execution

[Summarize any updates made to 1-TICKET-WALKTHROUGH.md during execution. If none, write "None."]

- [e.g. Step 4 updated to reflect that the BCIL scope was broader than originally described]

---

## Follow-Up Items

[Work that was deferred, discovered as out of scope, or blocked. Create tracker tickets for each item.]

| Item | Description | Priority | Ticket |
|---|---|---|---|
| [Short label] | [What needs to be done and why it was deferred] | High / Medium / Low | [TICKET-ID or TBD] |

---

## Appendix

[Optional. Include raw query outputs, backup records, or supporting data that is too detailed for the main body but should be preserved for future reference.]
