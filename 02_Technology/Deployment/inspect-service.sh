#!/usr/bin/env bash
# Read-only diagnostics. Usage: sudo bash inspect-service.sh example.service
set -u
if [[ $# -ne 1 || ! "$1" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.@:-]*\.service$ ]]; then
  echo "Usage: $0 example.service" >&2
  exit 2
fi
unit="$1"
for required in systemctl journalctl ss; do
  if ! command -v "$required" >/dev/null 2>&1; then
    echo "Missing command: $required" >&2
    exit 2
  fi
done
result=0
echo "Service state (inactive/failed returns nonzero):"
systemctl status "$unit" --no-pager -l || result=1
echo "Loaded service definition:"
systemctl cat "$unit" || result=1
echo "Recent service journal:"
journalctl -u "$unit" -n 100 --no-pager -o short-iso || result=1
echo "TCP listeners (process details may require privileges):"
ss -lntp || result=1
exit "$result"
