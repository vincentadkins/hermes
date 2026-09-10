# Workspace

This is the default `WORKSPACE` for the ticket workflow. Each ticket gets its own
folder that moves through three lifecycle stages:

| Folder | Meaning | Set by |
|---|---|---|
| `open/` | Ticket captured but work not started. Usually just `0-TICKET.md`. | Phase 1 in capture-only mode |
| `in-progress/` | Ticket actively being worked. All five documents live here. | Phase 1 (default), or moved from `open/` when planning starts |
| `closed/` | Ticket finalized. Report is complete and reviewed. | Phase 4, after handoff |

`closed/` doubles as reference material: the research step of future tickets searches
it for related prior work, so completed tickets keep paying off.

The **contents** of these three folders are gitignored. Real ticket folders can hold
sensitive data (internal identifiers, queries, ticket details), and this repo is
public, so nothing under `open/`, `in-progress/`, or `closed/` is ever committed. Only
the empty folders are tracked, via `.gitkeep`.

If you would rather keep tickets entirely outside this repo, point `WORKSPACE` at any
other directory in the RUNBOOK Paths block and create the three folders there:

```bash
mkdir -p ~/your/workspace/{open,in-progress,closed}
```
