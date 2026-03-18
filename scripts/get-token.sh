#!/usr/bin/env bash
set -euo pipefail

# Ensure Docker is available
if ! command -v docker &>/dev/null; then
  for path in /usr/local/bin/docker /Applications/Docker.app/Contents/Resources/bin/docker; do
    if [[ -x "$path" ]]; then
      export PATH="$(dirname "$path"):$PATH"
      break
    fi
  done
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

if ! docker compose ps k3s-server 2>/dev/null | grep -q "Up"; then
  echo "Error: k3s server is not running. Start it with: ./scripts/start-server.sh"
  exit 1
fi

TOKEN=$(docker compose exec -T k3s-server cat /var/lib/rancher/k3s/server/node-token 2>/dev/null | tr -d '\r')
echo "$TOKEN"
