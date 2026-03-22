# Demo 1: ArgoCD Application with Raw Kubernetes Manifests

This demo demonstrates how to deploy an application using ArgoCD with raw Kubernetes YAML manifests. It shows the basic GitOps workflow where ArgoCD monitors a Git repository and automatically synchronizes Kubernetes resources.

## Overview

This demo deploys a simple web application using:
- **Deployment**: 5 replicas of the ArgoCD Rollouts demo application
- **Service**: ClusterIP service exposing the application on port 8080
- **Ingress**: NGINX ingress for external access via `demo.local`
- **ArgoCD Application**: Automated sync with prune and self-heal enabled

## Prerequisites

- **Kubernetes cluster**: [Vanilla Kubernetes setup](../vanila_kuberentes/README.md) completed (provides NGINX Ingress)
- **ArgoCD installed**: Complete [demo_0](../demo_0/README.md) first
- kubectl configured and connected to your cluster
- Git repository configured in ArgoCD (from demo_0)

> **Note**: The NGINX Ingress Controller is already installed if you followed the [vanilla Kubernetes setup](../vanila_kuberentes/README.md).

## Structure

```
demo_1/
├── README.md
├── application_manifests/    # Kubernetes manifests for the application
│   ├── deployment.yaml       # Application deployment (5 replicas)
│   ├── service.yaml          # ClusterIP service
│   └── ingress.yaml          # NGINX ingress configuration
└── apps/
    └── demo_app.yaml         # ArgoCD Application definition
```

## Installation

### 1. Verify NGINX Ingress Controller

If you completed the [vanilla Kubernetes setup](../vanila_kuberentes/README.md), the NGINX Ingress Controller is already running:

```bash
# Verify ingress controller is running
kubectl get pods -n ingress-nginx

# You should see the ingress-nginx-controller pod in Running state
```

### 2. Deploy the ArgoCD Application

```bash
kubectl apply -f apps/demo_app.yaml
```

This will create an ArgoCD Application that:
- Monitors the `demo_1/application_manifests` directory in the Git repository
- Automatically syncs changes from the `main` branch
- Deploys resources to the `default` namespace
- Prunes resources that are removed from Git
- Self-heals if resources are modified manually

### 3. Add demo.local to /etc/hosts

```bash
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts
```

## ArgoCD Features Demonstrated

### Automated Sync

The application is configured with automated sync enabled:
```yaml
syncPolicy:
  automated:
    enabled: true
    prune: true
    selfHeal: true
```

- **enabled**: ArgoCD automatically syncs changes from Git
- **prune**: Resources deleted from Git are removed from the cluster
- **selfHeal**: Manual changes to resources are reverted to match Git

### GitOps Workflow

1. Make changes to manifests in `application_manifests/`
2. Commit and push to Git
3. ArgoCD detects changes automatically
4. Resources are synchronized to the cluster
5. View sync status in ArgoCD UI

## Testing Changes

Try modifying the deployment:

```bash
# Edit the number of replicas or the image tag
vim application_manifests/deployment.yaml

# Commit and push changes
git add application_manifests/deployment.yaml
git commit -m "Update demo deployment"
git push

# Watch ArgoCD sync the changes
kubectl get pods -w
```

## Application Details

- **Image**: `argoproj/rollouts-demo:green`
- **Replicas**: 5
- **Resources**: 
  - Requests: 100m CPU, 128Mi memory
  - Limits: 500m CPU, 256Mi memory
- **Health checks**: Readiness and liveness probes on port 8080
- **Strategy**: RollingUpdate with maxSurge=1, maxUnavailable=0

## Cleanup

To remove the application:

```bash
kubectl delete -f apps/demo_app.yaml
```

Or delete from ArgoCD UI with cascade delete enabled.

## Next Steps

- Explore [demo_2](../demo_2/README.md) to see how to use Helm charts with ArgoCD
- Experiment with different sync policies
- Try manual sync vs automated sync
- Test the self-heal feature by manually editing a resource
