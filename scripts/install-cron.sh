#!/usr/bin/env bash
# Install a cron entry that refreshes the GoAccess report every 5 minutes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CMD="$ROOT/goaccess/run-report.sh"
LINE="*/5 * * * * $CMD >/tmp/goaccess.log 2>&1"

# Append only if not already present.
# `crontab -l` returns 1 when no crontab exists yet — swallow that with || true.
{ crontab -l 2>/dev/null || true; } | grep -vF "$CMD" > /tmp/crontab.tmp || true
echo "$LINE" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm -f /tmp/crontab.tmp
echo "Installed cron:"
crontab -l | grep "$CMD"
