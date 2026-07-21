# Hermes Designer — deployment

A deployment of [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
being trained as a **graphic designer**, fed by the design intelligence produced by the
**Eternal** game.

## How the pieces fit

```
Eternal game ──▶ eternal/design-intelligence/   raw signals + distilled principles
                        │
                        │  eternal/ingest.py
                        ▼
        skills/graphic-design/ + training/tasks/
                        │
                        ▼
        Hermes agent (SOUL.md persona, learning loop ON)
          ├─ runs design tasks, consults the Eternal corpus
          ├─ self-improves its skills after each task   (built-in learning loop)
          └─ batch_runner generates design trajectories (training data)
```

Hermes' native learning loop does the heavy lifting: it creates and improves skills from
experience and curates its own memory. This deployment points that loop at graphic design
and gives it a growing corpus of design intelligence from Eternal.

## Layout

| Path | What it is |
|---|---|
| `config/config.yaml` | Hermes configuration for this deployment |
| `config/SOUL.md` | The agent's identity: a graphic designer in training |
| `skills/graphic-design/` | Core seed skill — the agent improves it in place as it learns |
| `skills/*` (7 more) | Specialist graphics skills vendored from hermes-agent's optional set: `baoyu-comic`, `baoyu-article-illustrator`, `pixel-art`, `concept-diagrams`, `creative-ideation`, `hyperframes`, `meme-generation` |
| `eternal/` | Design-intelligence drop zone + ingestion (see `eternal/README.md`) |
| `training/` | Batch trajectory generation for training runs |
| `scripts/deploy.sh` | One-command deploy (docker or local) |
| `docker-compose.yml` | Gateway + dashboard services |
| `data/` | Runtime HERMES_HOME (gitignored): sessions, memories, learned skills |

## Quickstart

```bash
cp .env.example .env         # add at least one LLM provider key
./scripts/deploy.sh local    # venv deploy — then: HERMES_HOME=$PWD/data hermes
./scripts/deploy.sh docker   # or containerized gateway + dashboard
```

The deploy script clones/updates `hermes-agent/`, seeds `data/` (config, SOUL.md, seed
skills) without clobbering anything the agent has already learned, and links the Eternal
corpus to `data/eternal` so the agent always finds it at `$HERMES_HOME/eternal`.

## Eternal game wiring

Two paths feed the loop; both are set up by `deploy.sh`:

**Push (live).** The gateway runs a webhook server; the game POSTs signals to it.
Signals are validated, deduped, appended to `signals/inbox.jsonl`, and ingestion
re-runs automatically — all without waking the LLM (zero token cost per signal).
Set `WEBHOOK_SECRET` in `.env`, run `hermes gateway`, then from the game:

```bash
BODY='{"id":"sig-001","type":"rating","task":"poster","summary":"..."}'
SIG=$(printf '%s' "$BODY" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" -hex | awk '{print $NF}')
curl -X POST http://<host>:8644/webhooks/eternal-signal \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=$SIG" -d "$BODY"
```

Batches work too: `{"signals": [...]}`. Invalid or duplicate signals are
rejected per-item; a forged signature gets a 401.

**Practice (nightly).** A `eternal-practice` cron job (03:00, created by
`deploy.sh local`) re-ingests the corpus, picks one untried task, runs the full
graphic-design workflow, saves the artifact under `data/studio/<date>/`, logs to
`data/studio/practice-log.md`, and folds lessons back into skills and memory.
The gateway hosts the cron scheduler; without a long-running gateway, fire it
manually with `hermes cron run eternal-practice` + `hermes cron tick`.

**Manual drops** still work: put JSONL files in
`eternal/design-intelligence/signals/` and run `python3 eternal/ingest.py`.
Ingestion refreshes `digest.md` (what the agent reads) and regenerates
`training/tasks/eternal-design-tasks.jsonl` (what datagen consumes).

## Generating training trajectories

```bash
./training/run-design-datagen.sh          # uses seed + Eternal-derived tasks
```

Output lands in `hermes-agent/data/<run_name>/trajectories.jsonl`, compressible for
training token budgets via hermes' `trajectory_compressor.py`.
