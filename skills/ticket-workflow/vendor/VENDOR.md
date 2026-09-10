# Vendored: ticket-workflow-template

`ticket-workflow-template/` is an unmodified copy of an upstream repository. It
is vendored rather than cloned so the five ticket documents are present at
`$HERMES_HOME/skills/ticket-workflow/vendor/...` after `scripts/deploy.sh` seeds
`skills/`, with no network fetch at ticket time.

| | |
|---|---|
| Upstream | https://github.com/franklioxygen/ticket-workflow-template |
| Pinned commit | `59de20ba553fee71d0ea32d08f036e66cf43f244` |
| Commit subject | Rename ticket/ to template/ |
| Commit date | 2026-08-04 |
| Vendored on | 2026-09-10 |
| Local modifications | None |

## Licensing

The upstream repository ships no LICENSE file and states no license terms. It
is public, and nothing here is redistributed beyond this private deployment.
Before any of this content reaches a public surface, get terms from the upstream
author.

## Divergence policy

Do not edit anything under `ticket-workflow-template/`. Deployment-specific
behavior — paths, the reviewer substitution, workspace location, what happens
after a ticket closes — lives in `../SKILL.md`, which the agent reads first.
Keeping the vendored tree byte-identical is what makes a future sync a plain
directory replace.

If a change genuinely belongs upstream, record it here as a row below and send
it upstream rather than patching in place.

| Date | Divergence | Why | Upstream status |
|---|---|---|---|
| — | none | — | — |

## Syncing

```bash
git clone https://github.com/franklioxygen/ticket-workflow-template /tmp/twt
rm -rf /tmp/twt/.git
rm -rf skills/ticket-workflow/vendor/ticket-workflow-template
mv /tmp/twt skills/ticket-workflow/vendor/ticket-workflow-template
```

Then update the pinned commit above, re-read `RUNBOOK.md` against `../SKILL.md`,
and fix the binding wherever upstream moved a path or renamed a phase.
