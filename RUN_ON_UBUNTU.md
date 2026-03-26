# Run on Ubuntu (one-command start)

This setup is containerized so you do not need Python/pip on the server.

## 1) Copy project to server
Copy this whole folder to your Ubuntu server.

## 2) Set your API key once
```bash
cp .env.example .env
nano .env
```
Set:
```env
SIMMER_API_KEY=sk_live_your_real_key
INTERVAL_SECONDS=60
```

## 3) Start with one command
```bash
docker compose up -d --build
```

## 4) Watch live output
```bash
docker compose logs -f weather-trader
```

## 5) Stop
```bash
docker compose down
```

The container continuously runs live scans internally with:
- `skills/polymarket-weather-trader/weather_trader.py --live`
- sleep interval from `INTERVAL_SECONDS`
