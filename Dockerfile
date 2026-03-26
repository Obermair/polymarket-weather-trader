FROM python:3.13-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHON_BIN=/usr/local/bin/python \
    INTERVAL_SECONDS=60

COPY . /app

RUN python -m pip install --upgrade pip && \
    python -m pip install simmer-sdk certifi

CMD ["sh", "-c", "if [ -z \"$SIMMER_API_KEY\" ]; then echo '❌ SIMMER_API_KEY is not set'; exit 1; fi; CERT_PATH=$(python -c 'import certifi; print(certifi.where())' 2>/dev/null || true); if [ -n \"$CERT_PATH\" ]; then export SSL_CERT_FILE=\"$CERT_PATH\"; fi; TRADER_PATH=$(find /app -type f -name weather_trader.py | head -n 1); if [ -z \"$TRADER_PATH\" ]; then echo '❌ weather_trader.py not found under /app'; echo '   Files under /app:'; find /app -maxdepth 4 -type f | sort; exit 1; fi; echo '▶️ Starting continuous live weather scans'; echo \"   Trader: $TRADER_PATH\"; echo \"   Interval: ${INTERVAL_SECONDS:-60}s\"; while true; do echo; echo \"[$(date '+%Y-%m-%d %H:%M:%S')] Running live scan...\"; python \"$TRADER_PATH\" --live; scan_exit=$?; if [ $scan_exit -ne 0 ]; then echo \"[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Scan exited with code $scan_exit\"; fi; echo \"[$(date '+%Y-%m-%d %H:%M:%S')] Sleeping ${INTERVAL_SECONDS:-60}s...\"; sleep ${INTERVAL_SECONDS:-60}; done"]
