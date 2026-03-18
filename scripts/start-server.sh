#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/output"

# Get Mac Mini IP (external IP for agent connectivity)
MAC_MINI_IP="${1:-}"
if [[ -z "$MAC_MINI_IP" ]]; then
  echo "Detecting Mac Mini IP..."
  if command -v ipconfig &>/dev/null; then
    MAC_MINI_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
  fi
  if [[ -z "$MAC_MINI_IP" ]]; then
    echo "Could not auto-detect IP. Please provide it as argument:"
    echo "  $0 <MAC_MINI_IP>"
    echo ""
    echo "Example: $0 192.168.1.100"
    exit 1
  fi
  echo "Using detected IP: $MAC_MINI_IP"
fi

mkdir -p "$OUTPUT_DIR"

# Export for docker-compose
export NODE_EXTERNAL_IP="$MAC_MINI_IP"

cd "$PROJECT_DIR"
echo "Starting k3s server..."
docker compose up -d

echo ""
echo "Waiting for k3s server to be ready..."
for i in {1..30}; do
  if docker compose exec k3s-server test -f /var/lib/rancher/k3s/server/node-token 2>/dev/null; then
    echo "k3s server is ready."
    break
  fi
  if [[ $i -eq 30 ]]; then
    echo "Timeout waiting for k3s server. Check logs: docker compose logs k3s-server"
    exit 1
  fi
  sleep 2
done

echo ""
echo "=== k3s Server Running ==="
echo "API: https://${MAC_MINI_IP}:6443"
echo ""
echo "To get the join token for gpu-node-1, run:"
echo "  ./scripts/get-token.sh"
echo ""
echo "Then on gpu-node-1, run:"
echo "  ./scripts/join-agent.sh ${MAC_MINI_IP} <TOKEN>"
echo ""
echo "Kubeconfig: $OUTPUT_DIR/kubeconfig.yaml"
echo "  export KUBECONFIG=$OUTPUT_DIR/kubeconfig.yaml"
echo "  kubectl get nodes"
