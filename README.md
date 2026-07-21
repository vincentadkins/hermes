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
| `skills/graphic-design/` | Seed skill — the agent improves it in place as it learns |
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

## Feeding it design intelligence

Drop Eternal exports into `eternal/design-intelligence/signals/` (JSONL, schema in
`eternal/README.md`), then:

```bash
python3 eternal/ingest.py
```

This refreshes the digest the agent reads and regenerates
`training/tasks/eternal-design-tasks.jsonl` for trajectory generation.

## Generating training trajectories

```bash
./training/run-design-datagen.sh          # uses seed + Eternal-derived tasks
```

Output lands in `hermes-agent/data/<run_name>/trajectories.jsonl`, compressible for
training token budgets via hermes' `trajectory_compressor.py`.
