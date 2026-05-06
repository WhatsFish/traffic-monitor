#!/usr/bin/env bash
# Generate the GoAccess HTML report from the personal-site Nginx access logs.
# Nginx logs are root-owned, so we read them via sudo.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/report/index.html"
CONF="$ROOT/goaccess.conf"

mkdir -p "$ROOT/report"

sudo --non-interactive bash -c '
  shopt -s nullglob
  for f in /var/log/nginx/personal-site.access.log /var/log/nginx/personal-site.access.log.*[!gz]; do
    [[ -e "$f" ]] && cat "$f"
  done
  for f in /var/log/nginx/personal-site.access.log.*.gz; do
    [[ -e "$f" ]] && zcat "$f"
  done
' | goaccess --config-file="$CONF" -o "$OUT" -

echo "Report written to $OUT"
