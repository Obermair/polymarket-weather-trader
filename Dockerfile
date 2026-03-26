FROM python:3.13-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHON_BIN=/usr/local/bin/python \
    INTERVAL_SECONDS=60

COPY skills /app/skills

RUN python -m pip install --upgrade pip && \
    python -m pip install simmer-sdk certifi

CMD ["sh", "-c", "if [ -z \"$SIMMER_API_KEY\" ]; then echo '❌ SIMMER_API_KEY is not set'; exit 1; fi; CERT_PATH=$(python -c 'import certifi; print(certifi.where())' 2>/dev/null || true); if [ -n \"$CERT_PATH\" ]; then export SSL_CERT_FILE=\"$CERT_PATH\"; fi; echo '▶️ Starting continuous live weather scans'; echo \"   Interval: ${INTERVAL_SECONDS:-60}s\"; while true; do echo; echo \"[$(date '+%Y-%m-%d %H:%M:%S')] Running live scan...\"; python /app/skills/polymarket-weather-trader/weather_trader.py --live; scan_exit=$?; if [ $scan_exit -ne 0 ]; then echo \"[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Scan exited with code $scan_exit\"; fi; echo \"[$(date '+%Y-%m-%d %H:%M:%S')] Sleeping ${INTERVAL_SECONDS:-60}s...\"; sleep ${INTERVAL_SECONDS:-60}; done"]
