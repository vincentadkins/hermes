#!/usr/bin/env python3
"""Webhook route script: receive Eternal design signals into the corpus.

Wired as the `script` of the gateway's `eternal-signal` webhook route
(seeded to $HERMES_HOME/scripts/eternal_signal.py by scripts/deploy.sh).
The gateway passes the authenticated POST payload as JSON on stdin.

Accepts either one signal object or a batch: {"signals": [...]} — schema in
eternal/README.md (required: id, type, task, summary). Valid new signals are
appended to design-intelligence/signals/inbox.jsonl and the digest + training
tasks are regenerated via ingest.py. Prints [SILENT] so signal ingestion
never wakes the LLM — the nightly practice job consumes the corpus instead.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

REQUIRED = ("id", "type", "task", "summary")
TYPES = {"choice", "rating", "outcome"}


def hermes_home() -> Path:
    env = os.getenv("HERMES_HOME")
    if env:
        return Path(env)
    # Script lives at $HERMES_HOME/scripts/eternal_signal.py
    return Path(__file__).resolve().parent.parent


def existing_ids(signals_dir: Path) -> set[str]:
    ids: set[str] = set()
    for path in signals_dir.glob("*.jsonl"):
        for line in path.read_text(encoding="utf-8").splitlines():
            try:
                sid = json.loads(line).get("id")
            except (json.JSONDecodeError, AttributeError):
                continue
            if sid:
                ids.add(sid)
    return ids


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"invalid JSON payload: {e}", file=sys.stderr)
        return 1

    signals = payload.get("signals") if isinstance(payload, dict) else None
    if signals is None:
        signals = [payload]
    if not isinstance(signals, list):
        print("payload must be a signal object or {'signals': [...]}", file=sys.stderr)
        return 1

    eternal = hermes_home() / "eternal"
    signals_dir = eternal / "design-intelligence" / "signals"
    if not signals_dir.is_dir():
        print(f"corpus not found at {signals_dir}", file=sys.stderr)
        return 1

    seen = existing_ids(signals_dir)
    accepted, rejected = [], 0
    for s in signals:
        if not isinstance(s, dict) or any(not s.get(k) for k in REQUIRED) \
                or s["type"] not in TYPES or s["id"] in seen:
            rejected += 1
            continue
        seen.add(s["id"])
        accepted.append(s)

    if accepted:
        inbox = signals_dir / "inbox.jsonl"
        with inbox.open("a", encoding="utf-8") as f:
            for s in accepted:
                f.write(json.dumps(s, ensure_ascii=False) + "\n")
        subprocess.run(
            [sys.executable, str(eternal / "ingest.py")],
            check=False, capture_output=True, timeout=60,
        )

    print(f"accepted={len(accepted)} rejected={rejected}", file=sys.stderr)
    # Never wake the agent for raw signal drops.
    print("[SILENT]")
    return 0


if __name__ == "__main__":
    sys.exit(main())
