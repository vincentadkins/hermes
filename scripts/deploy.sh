#!/bin/bash
# Deploy the Hermes Designer agent.
#
# Usage:
#   ./scripts/deploy.sh local    # venv install + seeded HERMES_HOME (default)
#   ./scripts/deploy.sh docker   # containerized gateway + dashboard
#
# Idempotent: re-running updates the hermes-agent clone and re-seeds data/
# WITHOUT overwriting anything the agent has changed since (config, SOUL.md,
# and skills are seeded no-clobber — the agent's learned edits win).
set -euo pipefail

MODE="${1:-local}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_DIR="$ROOT/hermes-agent"
DATA="$ROOT/data"
VENV="${HERMES_VENV:-$HOME/.hermes/venvs/hermes-designer}"
UPSTREAM="https://github.com/NousResearch/hermes-agent.git"

log() { printf '\033[1;36m[deploy]\033[0m %s\n' "$*"; }

# ── 1. Upstream source ───────────────────────────────────────────────────────
if [ ! -d "$AGENT_DIR/.git" ]; then
  log "cloning hermes-agent"
  git clone "$UPSTREAM" "$AGENT_DIR"
else
  log "updating hermes-agent"
  git -C "$AGENT_DIR" pull --ff-only || log "WARN: pull failed (offline?) — using existing clone"
fi

# ── 2. Seed HERMES_HOME (data/) — no-clobber so learned state survives ──────
log "seeding $DATA"
mkdir -p "$DATA"/{cron,sessions,logs,memories,skills,scripts,studio}
cp -n "$ROOT/config/config.yaml" "$DATA/config.yaml" 2>/dev/null || true
cp -n "$ROOT/config/SOUL.md" "$DATA/SOUL.md" 2>/dev/null || true
cp -rn "$ROOT/skills/." "$DATA/skills/" 2>/dev/null || true
# Webhook route script — the gateway only runs scripts under $HERMES_HOME/scripts/.
cp -n "$ROOT/eternal/webhook/eternal_signal.py" "$DATA/scripts/eternal_signal.py" 2>/dev/null || true

if [ -f "$ROOT/.env" ]; then
  cp -n "$ROOT/.env" "$DATA/.env" 2>/dev/null || true
else
  touch "$DATA/.env"
fi
if ! grep -qE '^[A-Z_]*API_KEY=..' "$DATA/.env" 2>/dev/null; then
  log "WARN: no API key found in data/.env — copy .env.example to .env and fill it in"
fi

# ── 3. Deploy ───────────────────────────────────────────────────────────────
case "$MODE" in
  docker)
    command -v docker >/dev/null || { log "docker not found"; exit 1; }
    # eternal/ is mounted by docker-compose.yml; no link needed.
    log "building + starting gateway and dashboard"
    cd "$ROOT"
    HERMES_UID="$(id -u)" HERMES_GID="$(id -g)" docker compose up -d --build
    log "done — dashboard at http://127.0.0.1:9119 (tunnel in from remote hosts)"
    ;;
  local)
    command -v uv >/dev/null || { log "uv not found — install from https://docs.astral.sh/uv/"; exit 1; }
    # Venv lives OUTSIDE the tree (see hermes-agent/CONTRIBUTING.md: a venv inside
    # the workspace can be wiped by the agent's own relative-path commands).
    if [ ! -d "$VENV" ]; then
      log "creating venv at $VENV"
      uv venv "$VENV" --python 3.11
    fi
    log "installing hermes-agent (editable, [all,dev])"
    (cd "$AGENT_DIR" && VIRTUAL_ENV="$VENV" PATH="$VENV/bin:$PATH" uv pip install -q -e ".[all,dev]")
    # Expose the Eternal corpus at $HERMES_HOME/eternal (docker mounts it there).
    ln -sfn "$ROOT/eternal" "$DATA/eternal"
    log "smoke test"
    HERMES_HOME="$DATA" "$VENV/bin/hermes" --version
    # Nightly design-practice job (idempotent): re-ingest the corpus, do one
    # design study, update skills/memory. Runs when the gateway is up (it
    # hosts the cron scheduler) or via `hermes cron tick` from system cron.
    if ! HERMES_HOME="$DATA" "$VENV/bin/hermes" cron list 2>/dev/null | grep -q "eternal-practice"; then
      log "creating eternal-practice cron job"
      HERMES_HOME="$DATA" "$VENV/bin/hermes" cron add \
        --name "eternal-practice" \
        --skill graphic-design \
        "0 3 * * *" \
        "Nightly design practice. 1) Run 'python3 \$HERMES_HOME/eternal/ingest.py' in the terminal to refresh the Eternal digest; note the tasks file path it prints. 2) Read \$HERMES_HOME/eternal/design-intelligence/digest.md. 3) Read \$HERMES_HOME/studio/practice-log.md (if present) and pick ONE task from the tasks file you have not done before. 4) Execute the full graphic-design skill workflow on it: brief, research (cite Eternal principles), concept, artifact, one self-critique pass. Save the artifact under \$HERMES_HOME/studio/<today's date>/. 5) Append task id, artifact path, principles cited, and one lesson learned to \$HERMES_HOME/studio/practice-log.md. 6) If the lesson is reusable, fold it into the graphic-design skill (or the matching specialist skill) and your memory."
    else
      log "eternal-practice cron job already present"
    fi
    log "done — run it with:"
    echo "    HERMES_HOME=$DATA $VENV/bin/hermes            # interactive CLI"
    echo "    HERMES_HOME=$DATA $VENV/bin/hermes gateway    # gateway: Eternal webhook + cron scheduler"
    ;;
  *)
    echo "usage: $0 [local|docker]" >&2
    exit 2
    ;;
esac
