# Demo 2: ArgoCD with Helm Charts and OCI Registry

This demo demonstrates the "Golden Chart" pattern using ArgoCD with Helm charts stored in an OCI registry (Docker Hub). It shows how to separate chart templates from configuration values, enabling reusable infrastructure patterns across multiple applications.

## Overview

This demo introduces:
- **Golden Chart Pattern**: A reusable Helm chart published to an OCI registry
- **Multi-Source Applications**: ArgoCD application pulling from two sources (chart from OCI registry, values from Git)
- **Helm OCI Registry**: Using Docker Hub as a Helm chart repository
- **Values Separation**: Configuration values stored in Git, separate from the chart

## Architecture

```
┌─────────────────────────────────┐
│     Docker Hub (OCI Registry)   │
│   registry-1.docker.io          │
│   └── golden_chart:0.1.0        │
└─────────────────────────────────┘
              │
              │ Chart Source
              ▼
┌─────────────────────────────────┐
│        ArgoCD Application       │
│     (Multi-Source Config)       │
└─────────────────────────────────┘
              ▲
              │ Values Source
              │
┌─────────────────────────────────┐
│     Git Repository              │
│   demo_2/application_values/    │
│   └── values.yaml               │
└─────────────────────────────────┘
```

## Prerequisites

- **Kubernetes cluster**: [Vanilla Kubernetes setup](../vanila_kuberentes/README.md) completed (provides NGINX Ingress)
- **ArgoCD installed**: Complete [demo_0](../demo_0/README.md) first
- Helm 3.8+ (with OCI support) for publishing charts
- Docker Hub account (for hosting Helm charts in OCI registry)
- kubectl configured and connected to your cluster

> **Note**: The NGINX Ingress Controller is already installed if you followed the [vanilla Kubernetes setup](../vanila_kuberentes/README.md).

## Structure

```
demo_2/
├── README.md
├── golden_chart/              # Reusable Helm chart templates
│   ├── Chart.yaml             # Chart metadata (v0.1.0)
│   └── templates/
│       ├── deployment.yml     # Templated deployment
│       ├── service.yml        # Templated service
│       └── ingress.yml        # Templated ingress
├── application_values/        # Application-specific configuration
│   └── values.yaml            # Values for this deployment (10 replicas, green version)
└── apps/
    └── demo_app.yaml          # ArgoCD Application (multi-source)
```

## Golden Chart Pattern

The Golden Chart is a reusable Helm chart that provides standardized Kubernetes resources. Benefits include:

- **Consistency**: Same deployment patterns across all applications
- **Centralized Updates**: Update the chart once, all apps benefit
- **Separation of Concerns**: Chart templates (infrastructure) separate from values (configuration)
- **Version Control**: Chart versions allow controlled rollouts

## Publishing the Helm Chart to Docker Hub

### 1. Login to Docker Hub Registry

```bash
helm registry login registry-1.docker.io
# Enter your Docker Hub username and password/token
```

### 2. Package the Helm Chart

```bash
cd demo_2
helm package golden_chart
```

This creates `golden_chart-0.1.0.tgz` in the current directory.

### 3. Push to Docker Hub OCI Registry

```bash
helm push golden_chart-0.1.0.tgz oci://registry-1.docker.io/YOUR_USERNAME
```

Replace `YOUR_USERNAME` with your Docker Hub username.

**Note**: The chart is now available at `registry-1.docker.io/YOUR_USERNAME/golden_chart:0.1.0`

### 4. Configure Docker Hub Repository in ArgoCD

You need to add the Docker Hub registry credentials to ArgoCD:

**Via ArgoCD UI:**
1. Navigate to Settings → Repositories
2. Click "Connect Repo"
3. Choose "Helm" as connection method
4. Select "OCI" as repository type
5. Enter:
   - **Name**: `docker-hub` (or any name)
   - **Repository URL**: `registry-1.docker.io/YOUR_USERNAME`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub password or access token

**Via kubectl:**
```bash
kubectl create secret generic docker-hub-helm \
  -n argocd \
  --from-literal=username=YOUR_USERNAME \
  --from-literal=password=YOUR_PASSWORD_OR_TOKEN

kubectl label secret docker-hub-helm \
  -n argocd \
  argocd.argoproj.io/secret-type=repository
```

## Deploying the Application

### 1. Update the ArgoCD Application Manifest

Edit `apps/demo_app.yaml` and replace `YOUR_USERNAME` with your Docker Hub username:

```yaml
sources:
  - repoURL: registry-1.docker.io/YOUR_USERNAME
    chart: golden_chart
    targetRevision: 0.1.0
```

### 2. Apply the ArgoCD Application

```bash
kubectl apply -f apps/demo_app.yaml
```

### 3. Monitor Deployment

```bash
# Watch ArgoCD sync
kubectl get applications -n argocd

# Watch pods being created
kubectl get pods -w

# Check deployment
kubectl get deployment demo
```

### 4. Access the Application

Add to `/etc/hosts` if not already present:
```bash
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts
```

With the Kind cluster from [vanilla Kubernetes setup](../vanila_kuberentes/README.md), ports 80 and 443 are already mapped.

Access directly at: http://demo.local

> **Note**: If not using the Kind cluster with port mappings, you may need to port-forward:
> ```bash
> kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80
> ```
> Then access at: http://demo.local:8081

## How Multi-Source Works

The ArgoCD Application uses two sources:

```yaml
sources:
  # Source 1: Helm chart from OCI registry
  - repoURL: registry-1.docker.io/mateuszwocka
    chart: golden_chart
    targetRevision: 0.1.0
    helm:
      valueFiles:
        - $values/demo_2/application_values/values.yaml
  
  # Source 2: Values file from Git repository
  - repoURL: https://github.com/mwocka/dev_opole.git
    targetRevision: main
    ref: values  # Referenced as $values in source 1
```

**Key Points:**
- Chart templates come from Docker Hub OCI registry
- Configuration values come from Git repository
- The `$values` reference allows source 1 to use files from source 2
- Changes to values in Git trigger automatic redeployment

## Customizing Values

The `application_values/values.yaml` file defines the deployment configuration:

```yaml
general:
  name: demo              # Application name
  namespace: default      # Target namespace
  version: green          # Image tag (green, blue, yellow, etc.)

replicaCount: 10          # Number of replicas

ingress:
  host: demo.local        # Ingress hostname
```

### Testing Value Changes

1. Modify `application_values/values.yaml`:
   ```yaml
   replicaCount: 15
   general:
     version: blue
   ```

2. Commit and push:
   ```bash
   git add application_values/values.yaml
   git commit -m "Scale to 15 replicas, switch to blue"
   git push
   ```

3. ArgoCD automatically syncs the changes
4. Watch the rollout: `kubectl get pods -w`

## Advantages Over Demo 1

| Aspect | Demo 1 (Raw Manifests) | Demo 2 (Golden Chart) |
|--------|------------------------|----------------------|
| **Reusability** | Copy/paste manifests | Reuse same chart |
| **Updates** | Update each app individually | Update chart once |
| **Configuration** | Edit full YAML | Change values only |
| **Version Control** | Git for everything | Chart versioned separately |
| **Consistency** | Manual enforcement | Enforced by chart |

## Updating the Chart

When you need to update the chart templates:

1. Modify templates in `golden_chart/templates/`
2. Update version in `golden_chart/Chart.yaml`:
   ```yaml
   version: 0.2.0
   ```
3. Package and push:
   ```bash
   helm package golden_chart
   helm push golden_chart-0.2.0.tgz oci://registry-1.docker.io/YOUR_USERNAME
   ```
4. Update `apps/demo_app.yaml`:
   ```yaml
   targetRevision: 0.2.0
   ```
5. Commit and push - ArgoCD syncs automatically

## Troubleshooting

### Chart Not Found
- Verify Docker Hub credentials in ArgoCD
- Check repository URL matches your username
- Ensure chart was pushed successfully: `helm pull oci://registry-1.docker.io/YOUR_USERNAME/golden_chart --version 0.1.0`

### Values Not Applied
- Verify the `$values` reference matches the second source's `ref`
- Check the path to values file is correct
- View rendered manifests in ArgoCD UI

### Authentication Issues
- Regenerate Docker Hub access token
- Update secret in ArgoCD namespace
- Verify repository connection in ArgoCD UI

## Cleanup

```bash
kubectl delete -f apps/demo_app.yaml
```

## Next Steps

- Create additional value files for different environments (dev, staging, prod)
- Build a library of golden charts for different application types
- Implement chart versioning strategy for controlled rollouts
- Explore Helm chart dependencies and sub-charts
- Compare with App of Apps pattern for managing multiple applications

