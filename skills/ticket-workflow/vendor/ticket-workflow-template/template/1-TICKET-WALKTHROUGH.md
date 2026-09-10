# [TICKET-ID] Walkthrough: [Ticket Title]

| Field | Value |
|---|---|
| **Ticket** | [TICKET-ID] |
| **Author** | [Name] |
| **Date Created** | [YYYY-MM-DD] |
| **Last Updated** | [YYYY-MM-DD] |
| **Version** | 1.0 |
| **Status** | Draft / In Progress / Complete |
| **Ticket Link** | [URL] |

---

## Relevant Documents

| Document | URL | Why It Matters |
|---|---|---|
| [Doc Name] | [URL] | [What decisions or context this doc unlocks] |
| [Doc Name] | [URL] | [What decisions or context this doc unlocks] |

---

## What This Ticket Is

[2-4 sentences. Describe the problem or feature in plain terms. Include the data path or system components involved. For bug tickets, show the propagation chain. For feature tickets, state what is being built and why.]

```
[For bug tickets — show the propagation chain, e.g.:]
Source Stage
  -> Intermediate Dataset (RID or table name)
  -> Downstream Fact     (RID or table name)
  -> Final Output        (RID or table name)
```

## Scope of Work

| [Dimension] | [Fix / Action] | [Affected Records / Notes] |
|---|---|---|
| [e.g. Payer / Component] | [e.g. Trim trailing X from MBI] | [e.g. 9 DLR rows, 8 unique MBIs] |

---

<!-- ============================================================
     OPEN DECISIONS — use only when human sign-off is required
     before implementation can proceed. Delete section if unused.
     ============================================================ -->

## Open Decisions

These items cannot be resolved by reading local docs or the codebase. Each must be answered by a named human and recorded before merge.

| # | Unknown | How to Confirm | Likely Owner |
|---|---|---|---|
| D1 | [What is unknown] | [Concrete action to get the answer] | [Team or person] |
| D2 | [What is unknown] | [Concrete action to get the answer] | [Team or person] |

---

## References

- Source ticket: [ticket.md](./ticket.md)
- [Link to prior investigation or related deliverable]
- [Foundry repo / code repo / dataset RID]
- [Files to modify:]
  - `[path/to/file.py]`
  - `[path/to/file.py]`

---

## Step 1 — [Pre-Flight / Setup / Context]

[What to confirm or set up before doing any work. For bug tickets this is a pre-fix baseline. For infra tickets this is environment access.]

**[Query 1 or Action 1] — [What it confirms]**

```sql
-- [Description of what this query checks]
SELECT ...
FROM `[dataset RID or table]`
WHERE ...
```

**Actual result (pre-fix baseline):** [N rows. Description of what was found. This becomes the before-state to compare against post-fix.]

---

## Step 2 — [Understand / Design / Locate]

[Background knowledge needed before implementing. For bug tickets: format specs, data invariants. For feature tickets: architecture decisions, source contracts, landing paths.]

[Include tables, regex patterns, format rules, or design constraints that inform the implementation.]

| [Field] | [Value / Rule] |
|---|---|
| [e.g. Valid format] | [e.g. Exactly 11 characters matching `^[1-9]...`] |
| [e.g. Invalid pattern] | [e.g. Valid 11-char base + trailing "X"] |

---

## Step 3 — [Locate / Navigate]

[How to find the specific code, config, or resource that needs changing. Include repo names, file paths, RIDs, search terms, and what to look for.]

**Repo:** `[repo-name or RID]`

Navigate to:
```
[path/to/relevant/directory/]
```

Identify:
1. [What to find and how to recognize it]
2. [What to find and how to recognize it]

Search terms:
```
[keyword1]
[keyword2]
```

---

## Step 4 — [Implement Fix / Build Component]

[The actual code change or infrastructure action. For bug tickets: the exact logic to add. For feature tickets: the implementation with code samples.]

**In [PySpark / Terraform / YAML / Python]:**

```python
# [Description of what this code does and why]
...
```

**[Query N] — [Preview or validate the change before committing]**

```sql
SELECT ...
FROM `[dataset RID or table]`
WHERE ...
```

**Actual result:** [N rows. What the preview confirmed. Explain any nuances or surprises.]

**Placement:** [Where exactly in the codebase or config to add this logic.]

**Guard condition:** [What ensures this change is scoped correctly and does not regress valid data.]

---

## Step 5 — [Second Fix / Complementary Change]

[If there is a second distinct fix or component — e.g., a drop filter in addition to a normalization. Follow the same pattern as Step 4.]

---

## Step 6 — [Pre-Commit Validation / Integration Test]

[Run these checks before saving or merging. Confirm the fix produces the expected output. Confirm valid/unchanged data is not affected.]

**[Query N] — [Regression check description]**

```sql
SELECT ...
FROM `[dataset RID or table]`
WHERE ...
```

**Actual result:** [N rows. What "pass" looks like here.]

---

## Step 7 — [Rebuild Order / Deploy]

[The exact sequence in which to trigger rebuilds, run Terraform applies, or deploy via CI/CD. Order matters — list each step explicitly.]

1. **[Dataset / Component]** — [why this goes first, full rebuild vs. incremental]
2. **[Dataset / Component]** (`[RID or path]`) — [full rebuild or incremental covering which files/dates]
3. **[Dataset / Component]** — [rebuild]
4. ...

[For CI/CD: list branch, PR, review, and deploy steps.]

---

## Step 8 — [Post-Rebuild Verification / Smoke Test]

[Queries or checks to run after the rebuild or deploy completes. Confirm the fix worked. Confirm counts and distributions match expectations.]

**[Query N] — Primary check: [what must be true]**

```sql
SELECT ...
FROM `[dataset RID or table]`
WHERE ...
```

**Pre-fix baseline:** [What this returned before.] **Target post-fix:** [What it must return now.]

**[Query N+1] — [Secondary check]**

```sql
SELECT ...
```

**Pre-fix baseline:** [Baseline.] After fix: [Expected outcome.]

---

## Step 9 — [Follow-Up / Downstream Confirmation]

[Any downstream systems (Kafka, domain API, external consumers) that need to be verified or triggered after the pipeline change is confirmed clean. Delete if not applicable.]

[Include any API calls, domain analysis steps, or follow-up tickets to file.]

---

## Step 10 — [Ticket Update / PR Description Template]

[A no-PHI summary to paste directly into your tracker or the PR description. Fill in the blanks after the fix is confirmed.]

```
Summary
- [What was fixed and at what layer]
- [Scope: N records affected, M unique identifiers]

Changes
- [Component A]: [What was changed and the exact condition / guard]
- [Component B]: [What was changed and the exact condition / guard]

Rebuild sequence
- [Stage] -> [Fact] -> [Output]

Verification
- [Primary check]: [Result]
- [Secondary check]: [Result]
- [Regression check]: [Result — no regressions]
```

---

## Acceptance Criteria Mapping

| Criterion | How It Is Satisfied |
|---|---|
| [Criterion from ticket.md verbatim] | [What step / code / query / action fulfills it] |
| [Criterion from ticket.md verbatim] | [What step / code / query / action fulfills it] |
| [Criterion from ticket.md verbatim] | [What step / code / query / action fulfills it] |

---

## Done Criteria

- [ ] [Code or config change implemented and reviewed]
- [ ] [All downstream components rebuilt in the correct order]
- [ ] [Primary verification query returns expected result]
- [ ] [Regression check confirms no unintended changes]
- [ ] [Downstream / domain follow-up completed or filed as a follow-up ticket]
- [ ] [Tracker updated with no-PHI summary]
- [ ] [Open Decisions resolved and recorded (if applicable)]
