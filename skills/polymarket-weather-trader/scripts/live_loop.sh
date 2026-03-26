#!/usr/bin/env sh
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
SKILL_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd -- "${SKILL_DIR}/../.." && pwd)"

INTERVAL_SECONDS="${INTERVAL_SECONDS:-60}"
PYTHON_BIN="${PYTHON_BIN:-${REPO_ROOT}/.venv/bin/python}"

if [ ! -x "${PYTHON_BIN}" ]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
  else
    echo "❌ No Python interpreter found. Set PYTHON_BIN or install python3."
    exit 1
  fi
fi

if [ -z "${SIMMER_API_KEY:-}" ]; then
  echo "❌ SIMMER_API_KEY is not set."
  echo "   Export it first: export SIMMER_API_KEY=\"sk_live_...\""
  exit 1
fi

CERT_PATH="$(${PYTHON_BIN} -c 'import certifi; print(certifi.where())' 2>/dev/null || true)"
if [ -n "${CERT_PATH}" ]; then
  export SSL_CERT_FILE="${CERT_PATH}"
fi

echo "▶️  Starting continuous live weather scans"
echo "   Python: ${PYTHON_BIN}"
echo "   Interval: ${INTERVAL_SECONDS}s"
echo "   Press Ctrl+C to stop"

while true; do
  echo
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running live scan..."
  "${PYTHON_BIN}" "${SKILL_DIR}/weather_trader.py" --live
  scan_exit=$?
  if [ ${scan_exit} -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  Scan exited with code ${scan_exit}"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sleeping ${INTERVAL_SECONDS}s..."
  sleep "${INTERVAL_SECONDS}"
done
