# Demo 0: ArgoCD Installation and Setup

This demo demonstrates how to install and configure ArgoCD with local SSL certificates and repository access.

## Prerequisites

- **Kubernetes cluster with NGINX Ingress**: Complete [vanilla Kubernetes setup](../vanila_kuberentes/README.md) first
- kubectl configured and connected to your cluster
- Helm 3.x installed
- mkcert for local SSL certificates (for HTTPS access to ArgoCD UI)

> **Important**: This demo assumes you have completed the [vanilla Kubernetes setup](../vanila_kuberentes/README.md) which provides a Kind cluster with NGINX Ingress Controller pre-configured.

## Setup Instructions

### 1. Install mkcert and Generate Certificates

```bash
# Install mkcert (macOS)
brew install mkcert

# Install the local CA
mkcert -install

# Generate certificates for argocd.local
mkcert argocd.local
```

The certificates will be created in the current directory. Move them to the `certs/` folder:
```bash
mv argocd.local.pem argocd.local-key.pem certs/
```

### 2. Install ArgoCD with Helm

```bash
# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd

# Install ArgoCD with custom values
helm install argocd argo/argo-cd -n argocd -f argocd/values.yaml
```

### 3. Configure SSL/TLS

```bash
# Create TLS secret for ArgoCD server
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=certs/argocd.local.pem \
  --key=certs/argocd.local-key.pem
```

### 4. Set Up Repository Access

```bash
# Apply repository configuration
kubectl apply -f repos/repo.yaml
```

### 5. Get Admin Password

```bash
# Retrieve the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo  # Add newline for readability
```

### 6. Access ArgoCD UI

Add the following entry to your `/etc/hosts` file:
```
127.0.0.1 argocd.local
::1       argocd.local
```

With the Kind cluster from [vanilla Kubernetes setup](../vanila_kuberentes/README.md), you need to access ArgoCD through an ingress or port-forward.

**Option 1: Port-forward (Recommended for demo)**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then access at: https://argocd.local:8080
- Username: `admin`
- Password: (from step 5)

**Option 2: Configure Ingress**
Create an ingress resource to access ArgoCD via the NGINX Ingress Controller on standard ports.

## Configuration Files

- `argocd/values.yaml` - Custom Helm values for ArgoCD installation
- `repos/repo.yaml` - Repository credentials for accessing Git repositories
- `certs/` - Directory containing SSL certificates for HTTPS access

## Cleanup

To remove ArgoCD:
```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```
