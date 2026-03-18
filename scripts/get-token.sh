#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

if ! docker compose ps k3s-server 2>/dev/null | grep -q "Up"; then
  echo "Error: k3s server is not running. Start it with: ./scripts/start-server.sh"
  exit 1
fi

TOKEN=$(docker compose exec k3s-server cat /var/lib/rancher/k3s/server/node-token 2>/dev/null | tr -d '\r')
echo "$TOKEN"
