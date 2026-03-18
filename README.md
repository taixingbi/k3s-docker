# k3s Cluster: Mac Mini Server + Linux GPU Worker

A hybrid k3s cluster with the control plane running in Docker on Mac Mini and an NVIDIA GPU worker node on Linux (gpu-node-1).

## Architecture

- **Mac Mini (Docker)**: k3s server runs in a container; no workloads run here
- **gpu-node-1 (Linux)**: Native k3s agent with NVIDIA GPU support for GPU workloads

## Prerequisites

| Component | Requirement |
|-----------|-------------|
| Mac Mini | Docker Desktop with Linux containers |
| gpu-node-1 | Ubuntu 22.04 or similar; NVIDIA driver pre-installed (`nvidia-smi` works) |
| Network | Both nodes must reach each other (same LAN recommended) |

## Quick Start

### 1. Start k3s Server on Mac Mini

```bash
# Auto-detect IP or provide explicitly
./scripts/start-server.sh
# or
./scripts/start-server.sh 192.168.1.100
```

### 2. Get Join Token

```bash
./scripts/get-token.sh
# K106daa391cff102c6220a41e795c0a745783a6a54d0ce6899e14fda6fd729d7938::server:78b9b97ebb8a3c9a9611706f3d5a7e60
```

### 3. Setup GPU Node (on gpu-node-1)

```bash
# Copy scripts to gpu-node-1, then run:
./scripts/setup-gpu-node.sh
```

### 4. Join Agent (on gpu-node-1)

```bash
./scripts/join-agent.sh 192.168.1.100 K106daa391cff102c6220a41e795c0a745783a6a54d0ce6899e14fda6fd729d7938::server:78b9b97ebb8a3c9a9611706f3d5a7e60
```

### 5. Deploy NVIDIA Device Plugin (from Mac Mini)

```bash
export KUBECONFIG=./output/kubeconfig.yaml
kubectl apply --validate=false -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.13.0/nvidia-device-plugin.yml
```

### 6. Verify

```bash
export KUBECONFIG=./output/kubeconfig.yaml
kubectl get nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu
```

### 7. Test GPU Workload

```bash
kubectl apply --validate=false -f manifests/gpu-test-pod.yaml
kubectl logs gpu-test
```

## Network Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 6443 | TCP | Kubernetes API (Mac Mini must allow inbound) |
| 8472 | UDP | Flannel VXLAN (pod networking between nodes) |

Ensure firewall rules allow these between Mac Mini and gpu-node-1.

## GPU Pods

GPU workloads require `runtimeClassName: nvidia` in the Pod spec:

```yaml
spec:
  runtimeClassName: nvidia
  containers:
    - name: my-gpu-app
      image: nvidia/cuda:12.0-base
      resources:
        limits:
          nvidia.com/gpu: 1
```

## Troubleshooting

- **Agent cannot connect**: Verify Mac Mini IP is correct, port 6443 is open, and TLS SAN includes the IP (set via `NODE_EXTERNAL_IP` in start-server.sh)
- **GPU not detected**: Run `./scripts/setup-gpu-node.sh` before joining; ensure NVIDIA driver is installed
- **kubeconfig server unreachable**: The default kubeconfig may use localhost; from Mac Mini, `127.0.0.1:6443` should work via port mapping. If `kubectl apply` fails during OpenAPI validation, retry with `kubectl apply --validate=false ...`
