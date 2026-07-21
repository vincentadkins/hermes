#!/bin/bash
# Generate graphic-design tool-calling trajectories with hermes-agent's batch runner.
#
# Prerequisites:
#   - ./scripts/deploy.sh has run (hermes-agent/ cloned, venv or docker image built)
#   - OPENROUTER_API_KEY in data/.env (plus FAL_KEY for image_generate,
#     BROWSERBASE_API_KEY if tasks use browser tools)
#   - Optional: python3 eternal/ingest.py to refresh eternal-design-tasks.jsonl
#
# Usage:
#   ./training/run-design-datagen.sh [extra batch_runner args...]
#
# Output: hermes-agent/data/design_datagen_<ts>/trajectories.jsonl
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_DIR="$ROOT/hermes-agent"
TASKS_DIR="$ROOT/training/tasks"
RUN_NAME="design_datagen_$(date +%Y%m%d_%H%M%S)"
DATASET="$ROOT/training/tasks/.combined-tasks.jsonl"

[ -d "$AGENT_DIR" ] || { echo "hermes-agent/ missing — run ./scripts/deploy.sh first" >&2; exit 1; }

# Combine seed tasks with the latest Eternal-derived tasks.
cat "$TASKS_DIR"/seed-design-tasks.jsonl "$TASKS_DIR"/eternal-design-tasks.jsonl 2>/dev/null > "$DATASET"
echo "dataset: $(wc -l < "$DATASET") tasks"

mkdir -p "$AGENT_DIR/logs"
LOG_FILE="$AGENT_DIR/logs/${RUN_NAME}.log"

cd "$AGENT_DIR"
HERMES_HOME="$ROOT/data" python batch_runner.py \
  --dataset_file="$DATASET" \
  --run_name="$RUN_NAME" \
  --distribution="image_gen" \
  --model="anthropic/claude-opus-4.6" \
  --base_url="https://openrouter.ai/api/v1" \
  --num_workers=3 \
  --batch_size=5 \
  --max_turns=40 \
  --ephemeral_system_prompt="You are a graphic designer agent. For every task: restate the brief, consult the Eternal design-intelligence corpus at \$HERMES_HOME/eternal/design-intelligence/ and cite principles that shape your decisions, produce the actual artifact as a file (SVG, HTML/CSS, or generated image), and run one self-critique pass against hierarchy, typography, color contrast (WCAG AA), spacing, and alignment before finishing." \
  "$@" \
  2>&1 | tee "$LOG_FILE"

echo "done — trajectories in $AGENT_DIR/data/$RUN_NAME/, log: $LOG_FILE"
