#!/usr/bin/env bash
# app_health_check.sh
# Usage: ./app_health_check.sh https://wisecow.example.com/health
LOGFILE="./app_health.log"
URL="$1"
TIMEOUT=10
if [ -z "$URL" ]; then
  echo "Usage: $0 <url>"
  exit 2
fi

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$URL") || status_code=000
if [ "$status_code" -ge 200 -a "$status_code" -lt 300 ]; then
  echo "$(timestamp) OK - $URL returned $status_code" | tee -a "$LOGFILE"
  exit 0
else
  echo "$(timestamp) FAILED - $URL returned $status_code" | tee -a "$LOGFILE"
  # optional restart hook or alert integration could be inserted here
  exit 1
fi

Make executable:

chmod +x scripts/app_health_check.sh
