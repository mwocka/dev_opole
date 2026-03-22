# Vanilla Kubernetes Setup with Kind

This directory contains the foundation setup for running all demos. It creates a local Kubernetes cluster using Kind (Kubernetes in Docker) with NGINX Ingress Controller pre-configured.

## Overview

This setup provides:
- **Multi-node Kind cluster**: 1 control-plane + 3 worker nodes
- **Ingress support**: Port mappings for HTTP (80) and HTTPS (443)
- **NGINX Ingress Controller**: Pre-configured and ready to use
- **Ingress-ready labels**: Nodes labeled for ingress pod scheduling

## Prerequisites

- Docker Desktop installed and running
- Kind (Kubernetes in Docker) installed
- kubectl installed

### Install Required Tools (macOS)

```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop

# Install kind
brew install kind

# Install kubectl
brew install kubectl

# Verify installations
docker --version
kind --version
kubectl version --client
```

## Quick Start

### 1. Create the Kind Cluster

```bash
cd vanila_kuberentes
kind create cluster --config kind-cluster.yaml --name argocd-demo
```

This creates a cluster with:
- 1 control-plane node (with port 80 and 443 exposed)
- 3 worker nodes
- All nodes labeled as `ingress-ready=true`

### 2. Verify Cluster

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Expected output: 4 nodes (1 control-plane, 3 workers)
```

### 3. Install NGINX Ingress Controller

```bash
# Make the script executable
chmod +x config.sh

# Run the configuration script
./config.sh
```

The script:
1. Deploys NGINX Ingress Controller for Kind
2. Patches the controller to run on ingress-ready nodes
3. Restarts the controller deployment

### 4. Verify Ingress Controller

```bash
# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Check ingress controller pods
kubectl get pods -n ingress-nginx

# Test ingress is responding
curl localhost
# Should return default 404 from nginx (this is expected)
```

## Cluster Configuration Details

### kind-cluster.yaml

```yaml
- 1 control-plane node with:
  - Port 80 → 80 (HTTP)
  - Port 443 → 443 (HTTPS)
  - Label: ingress-ready=true

- 3 worker nodes with:
  - Label: ingress-ready=true
```

### Port Mappings

| Service | Container Port | Host Port |
|---------|----------------|-----------|
| HTTP    | 80            | 80        |
| HTTPS   | 443           | 443       |

This allows direct access to ingress services without port-forwarding.

## What's Next?

Once the cluster is running, proceed with the demos in order:

1. **[demo_0](../demo_0/README.md)**: Install ArgoCD with SSL certificates
2. **[demo_1](../demo_1/README.md)**: Deploy application with raw Kubernetes manifests
3. **[demo_2](../demo_2/README.md)**: Deploy application using Helm charts from OCI registry

## Managing the Cluster

### View Cluster Status

```bash
# List all kind clusters
kind get clusters

# Get cluster details
kubectl cluster-info --context kind-argocd-demo

# View all resources
kubectl get all -A
```

### Stop/Start Cluster

Kind clusters stop when Docker stops. To manage:

```bash
# Stop Docker Desktop to stop the cluster
# Start Docker Desktop to restart the cluster

# After restart, verify cluster is accessible
kubectl get nodes
```

### Delete Cluster

```bash
# Delete the entire cluster
kind delete cluster --name argocd-demo

# Verify deletion
kind get clusters
```

## Troubleshooting

### Cluster Creation Fails

```bash
# Check Docker is running
docker ps

# Delete any existing cluster with the same name
kind delete cluster --name argocd-demo

# Try creating again
kind create cluster --config kind-cluster.yaml --name argocd-demo
```

### Ingress Not Working

```bash
# Check ingress controller status
kubectl get pods -n ingress-nginx

# View logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Restart ingress controller
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

### Port Already in Use

If ports 80 or 443 are already in use:

```bash
# Check what's using the ports
sudo lsof -i :80
sudo lsof -i :443

# Stop the conflicting service or modify kind-cluster.yaml to use different ports
```

### Cannot Connect to Cluster

```bash
# Check Docker is running
docker ps

# Verify cluster exists
kind get clusters

# Get cluster info
kubectl cluster-info --context kind-argocd-demo

# If context is not set
kubectl config use-context kind-argocd-demo
```

## Advanced Configuration

### Customize Node Count

Edit `kind-cluster.yaml` to add/remove worker nodes:

```yaml
# Add another worker
- role: worker
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
```

### Change Port Mappings

Modify the control-plane node's `extraPortMappings`:

```yaml
extraPortMappings:
  - containerPort: 80
    hostPort: 8080    # Change to 8080 if port 80 is in use
    protocol: TCP
```

### Multiple Clusters

Create multiple Kind clusters for different purposes:

```bash
# Create with different names
kind create cluster --config kind-cluster.yaml --name cluster1
kind create cluster --config kind-cluster.yaml --name cluster2

# Switch between clusters
kubectl config use-context kind-cluster1
kubectl config use-context kind-cluster2
```

## Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kind Ingress Guide](https://kind.sigs.k8s.io/docs/user/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)

## Files in This Directory

- `kind-cluster.yaml`: Kind cluster configuration (1 control-plane + 3 workers)
- `config.sh`: Script to install and configure NGINX Ingress Controller
- `README.md`: This file
