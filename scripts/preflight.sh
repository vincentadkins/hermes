#!/usr/bin/env bash
# Hermes Designer — egress preflight.
#
# Proves every network host the deployment needs is reachable BEFORE
# scripts/deploy.sh runs, so we never burn time deploying against a blocked
# provider. Read-only: it makes no changes and touches nothing on disk.
#
# What it checks (dynamically, based on your .env):
#   * LLM provider   — openrouter.ai by default, or api.anthropic.com if you
#                      switched to the Anthropic fallback (key-derived).
#   * Source + build — github.com, codeload.github.com (hermes-agent clone),
#                      pypi.org, files.pythonhosted.org (uv pip install).
#   * Optional tools — fal.run, api.browserbase.com — checked ONLY if the
#                      matching key is set, so you never get false alarms.
# If the provider host is open AND its key is present, it also does a real
# authenticated call to confirm the key itself works.
#
# Usage:
#   scripts/preflight.sh            # check everything, human-readable report
#   scripts/preflight.sh --quiet    # only print failures + the final verdict
#
# Exit codes:
#   0  all REQUIRED hosts reachable  (safe to deploy)
#   1  one or more REQUIRED hosts BLOCKED
#   2  bad usage
#   3  curl not available
#
# Tunables (env vars, all optional):
#   PREFLIGHT_RETRIES        attempts per host before giving up   (default 3)
#   PREFLIGHT_RETRY_DELAY    seconds between retries              (default 2)
#   PREFLIGHT_CONNECT_TIMEOUT / PREFLIGHT_MAX_TIME  curl timeouts (10 / 25)
#   NO_COLOR                 set to disable ANSI colour
set -u

# ── locate repo + env ────────────────────────────────────────────────────────
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Prefer the live HERMES_HOME .env, fall back to the repo-root .env.
if   [ -f "$ROOT/data/.env" ]; then ENV_FILE="$ROOT/data/.env"
elif [ -f "$ROOT/.env" ];      then ENV_FILE="$ROOT/.env"
else ENV_FILE="$ROOT/.env"  # nominal path; get_env tolerates it being absent
fi

QUIET=0
case "${1:-}" in
  ""|--quiet|-q) [ "${1:-}" = "--quiet" ] || [ "${1:-}" = "-q" ] && QUIET=1 || true ;;
  -h|--help) sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "usage: $0 [--quiet|--help]" >&2; exit 2 ;;
esac

command -v curl >/dev/null 2>&1 || { echo "preflight: curl not found — cannot check egress" >&2; exit 3; }

# ── tunables ─────────────────────────────────────────────────────────────────
RETRIES="${PREFLIGHT_RETRIES:-3}"
DELAY="${PREFLIGHT_RETRY_DELAY:-2}"
CONNECT_TIMEOUT="${PREFLIGHT_CONNECT_TIMEOUT:-10}"
MAX_TIME="${PREFLIGHT_MAX_TIME:-25}"

# ── colour (only on a TTY, and never when NO_COLOR is set) ───────────────────
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_G=$'\033[1;32m'; C_R=$'\033[1;31m'; C_Y=$'\033[1;33m'; C_C=$'\033[1;36m'; C_D=$'\033[2m'; C_0=$'\033[0m'
else
  C_G=""; C_R=""; C_Y=""; C_C=""; C_D=""; C_0=""
fi
say()  { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }
hdr()  { [ "$QUIET" -eq 1 ] || printf '%s[preflight]%s %s\n' "$C_C" "$C_0" "$*"; }
out()  { printf '%s\n' "$*"; }                                   # always prints (verdict/remediation)
prefixed() { printf '%s[preflight]%s %s\n' "$C_C" "$C_0" "$*"; } # always prints, [preflight]-tagged

# ── read a value from .env WITHOUT sourcing it (no code execution) ───────────
get_env() {
  local key="$1"
  [ -f "$ENV_FILE" ] || return 0
  grep -E "^[[:space:]]*${key}=" "$ENV_FILE" 2>/dev/null \
    | grep -vE '^[[:space:]]*#' \
    | tail -n1 \
    | sed -E "s/^[[:space:]]*${key}=//; s/^[\"']//; s/[\"'][[:space:]]*\$//; s/[[:space:]]*\$//" \
    || true
}

# ── probe one host: echoes "CODE|ERR"; CODE is the HTTP status or 000 ────────
probe() {
  local host="$1" attempt=1 code errfile err
  errfile="$(mktemp 2>/dev/null || echo "${TMPDIR:-/tmp}/preflight.$$.$host")"
  while : ; do
    : > "$errfile"
    code="$(curl -sS -o /dev/null -w '%{http_code}' \
              --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
              "https://${host}/" 2>"$errfile" || true)"
    [ -n "$code" ] || code="000"
    [ "$code" != "000" ] && break            # any HTTP reply == tunnel established
    [ "$attempt" -ge "$RETRIES" ] && break
    attempt=$((attempt + 1))
    [ "$DELAY" != "0" ] && sleep "$DELAY"
  done
  err="$(tr '\n' ' ' < "$errfile" 2>/dev/null | sed -E 's/[[:space:]]+/ /g; s/ *$//')"
  rm -f "$errfile" 2>/dev/null || true
  printf '%s|%s' "$code" "$err"
}

# ── turn a probe result into OPEN / a blocked-reason string ──────────────────
classify() {
  local code="$1" err="$2"
  if [ "$code" != "000" ]; then echo "OPEN"; return; fi
  if   printf '%s' "$err" | grep -qiE '403|forbidden|denied|policy'; then echo "network policy (proxy 403 on CONNECT)"
  elif printf '%s' "$err" | grep -qiE 'could not resolve|resolve host|name or service';  then echo "DNS resolution failed"
  elif printf '%s' "$err" | grep -qiE 'timed out|timeout';                                then echo "connection timed out"
  elif printf '%s' "$err" | grep -qiE 'refused';                                          then echo "connection refused"
  else echo "unreachable${err:+ ($err)}"; fi
}

# ── build the host list from config + which keys are present ─────────────────
# Each entry: "host|tier|purpose"   tier ∈ required | recommended | optional
ENTRIES=()
OPENROUTER_KEY="$(get_env OPENROUTER_API_KEY)"
ANTHROPIC_KEY="$(get_env ANTHROPIC_API_KEY)"
if [ -n "$ANTHROPIC_KEY" ] && [ -z "$OPENROUTER_KEY" ]; then
  LLM_HOST="api.anthropic.com"; LLM_PROVIDER="anthropic"
  ENTRIES+=("api.anthropic.com|required|LLM provider (Anthropic — fallback)")
else
  LLM_HOST="openrouter.ai"; LLM_PROVIDER="openrouter"
  ENTRIES+=("openrouter.ai|required|LLM provider (OpenRouter — config default)")
fi
ENTRIES+=("github.com|required|hermes-agent clone (git)")
ENTRIES+=("codeload.github.com|required|git clone data transport")
ENTRIES+=("pypi.org|required|Python package index (uv pip install)")
ENTRIES+=("files.pythonhosted.org|required|Python package downloads")
ENTRIES+=("objects.githubusercontent.com|recommended|git LFS / release assets")
[ -n "$(get_env FAL_KEY)" ]            && ENTRIES+=("fal.run|optional|FAL image generation (FLUX)")
[ -n "$(get_env BROWSERBASE_API_KEY)" ] && ENTRIES+=("api.browserbase.com|optional|Browserbase browser tools")

# ── run the checks ───────────────────────────────────────────────────────────
hdr "Hermes Designer egress preflight"
[ -n "${HTTPS_PROXY:-${https_proxy:-}}" ] && \
  hdr "proxy: ${HTTPS_PROXY:-$https_proxy} ${C_D}(network policy is snapshotted at container start)${C_0}"
if [ -f "$ENV_FILE" ]; then hdr "env:   $ENV_FILE"; else hdr "env:   $ENV_FILE ${C_D}(not found — assuming config defaults)${C_0}"; fi
say ""

FAIL_REQUIRED=0
WARN=0
LLM_OPEN=0
BLOCKED_REQUIRED=()

for entry in "${ENTRIES[@]}"; do
  host="${entry%%|*}"; rest="${entry#*|}"; tier="${rest%%|*}"; purpose="${rest#*|}"
  res="$(probe "$host")"; code="${res%%|*}"; err="${res#*|}"
  verdict="$(classify "$code" "$err")"

  if [ "$verdict" = "OPEN" ]; then
    [ "$host" = "$LLM_HOST" ] && LLM_OPEN=1
    icon="${C_G}✔${C_0}"; status="${C_G}OPEN${C_0}"; detail="HTTP ${code}   ${C_D}${purpose}${C_0}"
  else
    case "$tier" in
      required)
        icon="${C_R}✘${C_0}"; status="${C_R}BLOCKED${C_0}"; detail="${C_R}${verdict}${C_0}   ${C_D}${purpose}${C_0}"
        FAIL_REQUIRED=$((FAIL_REQUIRED + 1)); BLOCKED_REQUIRED+=("$host") ;;
      *)
        icon="${C_Y}!${C_0}"; status="${C_Y}WARN${C_0}"; detail="${C_Y}${verdict}${C_0}   ${C_D}${purpose} (${tier})${C_0}"
        WARN=$((WARN + 1)) ;;
    esac
  fi
  # Quiet mode prints only problems; full mode prints everything.
  if [ "$QUIET" -eq 0 ] || [ "$verdict" != "OPEN" ]; then
    printf '  %b %-30s %b %b\n' "$icon" "$host" "$status" "$detail"
  fi
done
say ""

# ── bonus: if the provider is reachable and we have its key, test the key ────
if [ "$LLM_OPEN" -eq 1 ]; then
  key_status=""
  if [ "$LLM_PROVIDER" = "openrouter" ] && [ -n "$OPENROUTER_KEY" ]; then
    c="$(curl -sS -o /dev/null -w '%{http_code}' --max-time "$MAX_TIME" \
           -H "Authorization: Bearer ${OPENROUTER_KEY}" https://openrouter.ai/api/v1/key 2>/dev/null || true)"
    case "$c" in 200) key_status="${C_G}OK — key accepted${C_0}";; 401|403) key_status="${C_R}REJECTED (HTTP $c) — key invalid/expired${C_0}";; *) key_status="${C_Y}inconclusive (HTTP $c)${C_0}";; esac
  elif [ "$LLM_PROVIDER" = "anthropic" ] && [ -n "$ANTHROPIC_KEY" ]; then
    c="$(curl -sS -o /dev/null -w '%{http_code}' --max-time "$MAX_TIME" \
           -H "x-api-key: ${ANTHROPIC_KEY}" -H "anthropic-version: 2023-06-01" https://api.anthropic.com/v1/models 2>/dev/null || true)"
    case "$c" in 200) key_status="${C_G}OK — key accepted${C_0}";; 401|403) key_status="${C_R}REJECTED (HTTP $c) — key invalid/expired${C_0}";; *) key_status="${C_Y}inconclusive (HTTP $c)${C_0}";; esac
  fi
  [ -n "$key_status" ] && hdr "provider key check (${LLM_PROVIDER}): ${key_status}"
fi

# ── verdict (always printed, even in --quiet — this is the actionable part) ──
if [ "$FAIL_REQUIRED" -eq 0 ]; then
  prefixed "${C_G}RESULT: all required hosts reachable — safe to deploy.${C_0}"
  [ "$WARN" -gt 0 ] && prefixed "${C_Y}(${WARN} optional/recommended host(s) warned — fine unless you use that feature.)${C_0}"
  exit 0
fi

prefixed "${C_R}RESULT: ${FAIL_REQUIRED} required host(s) BLOCKED — do NOT deploy yet.${C_0}"
out ""
out "  Blocked: ${BLOCKED_REQUIRED[*]}"
out ""
out "  To fix (network policy lives on the ENVIRONMENT, not in this container):"
out "    1. claude.ai/code  →  the environment for this repo  →  Network access"
out "    2. Add to the allowlist:"
for h in "${BLOCKED_REQUIRED[@]}"; do out "         ${h}"; done
out "    3. Save, then start a NEW session — a running container freezes its"
out "       network policy at start, so the change only lands in a fresh one."
out "    4. Re-run:  scripts/preflight.sh"
# Best-effort corroboration straight from the agent proxy, if present.
if [ -n "${HTTPS_PROXY:-}" ]; then
  fails="$(curl -sS --max-time 8 "${HTTPS_PROXY}/__agentproxy/status" 2>/dev/null | grep -iE '"(ts|kind|detail|host)"[[:space:]]*:' | head -8 || true)"
  [ -n "$fails" ] && { out ""; out "  Proxy's own recent-failure log:"; printf '%s\n' "$fails" | sed 's/^/    /'; }
fi
exit 1
