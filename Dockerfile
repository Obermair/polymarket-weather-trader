FROM python:3.13-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHON_BIN=/usr/local/bin/python \
    INTERVAL_SECONDS=60

COPY skills /app/skills

RUN python -m pip install --upgrade pip && \
    python -m pip install simmer-sdk certifi && \
    chmod +x /app/skills/polymarket-weather-trader/scripts/live_loop.sh

CMD ["/app/skills/polymarket-weather-trader/scripts/live_loop.sh"]
