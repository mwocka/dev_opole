# GitOps with ArgoCD - Demo Series

A comprehensive hands-on workshop demonstrating GitOps principles using ArgoCD, Kubernetes, and Helm.

## Overview

This repository contains a progressive series of demos that teach GitOps practices using ArgoCD. Each demo builds on the previous one, introducing new concepts and patterns.

## Demo Series Structure

### [Vanilla Kubernetes Setup](vanila_kuberentes/README.md)
**Foundation**: Local Kubernetes cluster with Kind and NGINX Ingress

Set up a multi-node Kind cluster with NGINX Ingress Controller pre-configured. This provides the foundation for all subsequent demos.

**You Learn:**
- Creating multi-node Kind clusters
- Configuring port mappings for ingress
- Installing and configuring NGINX Ingress Controller

**Prerequisites:** Docker Desktop, Kind, kubectl

---

### [Demo 0: ArgoCD Installation](demo_0/README.md)
**Goal**: Install and configure ArgoCD with SSL certificates

Install ArgoCD using Helm with custom configuration including SSL/TLS certificates and Git repository access.

**You Learn:**
- Installing ArgoCD with Helm
- Configuring SSL certificates with mkcert
- Setting up Git repository credentials
- Accessing the ArgoCD UI

**Prerequisites:** Vanilla Kubernetes cluster setup completed

---

### [Demo 1: Raw Kubernetes Manifests](demo_1/README.md)
**Goal**: Deploy applications using ArgoCD with raw YAML manifests

Deploy a simple web application using ArgoCD GitOps workflow with raw Kubernetes manifests.

**You Learn:**
- Creating ArgoCD Application resources
- Automated synchronization (sync policies)
- Self-healing and pruning
- Basic GitOps workflow
- Monitoring deployments in ArgoCD UI

**Prerequisites:** Demo 0 completed (ArgoCD installed)

**Key Concepts:**
- Declarative deployments from Git
- Automated sync with prune and self-heal
- GitOps change workflow

---

### [Demo 2: Helm Charts with OCI Registry](demo_2/README.md)
**Goal**: Use the Golden Chart pattern with Helm and OCI registries

Deploy applications using reusable Helm charts stored in Docker Hub OCI registry, with configuration values stored separately in Git.

**You Learn:**
- Creating reusable Helm charts (Golden Chart pattern)
- Publishing Helm charts to OCI registries (Docker Hub)
- Multi-source ArgoCD applications
- Separating templates from values
- Chart versioning and updates

**Prerequisites:** Demo 0 completed, Docker Hub account

**Key Concepts:**
- Infrastructure as code with reusable templates
- Chart/values separation for better organization
- OCI registry for chart distribution
- Multi-source application pattern

---

## Quick Start

### 1. Set Up the Kubernetes Cluster

```bash
cd vanila_kuberentes
kind create cluster --config kind-cluster.yaml --name argocd-demo
chmod +x config.sh
./config.sh
```

Verify cluster and ingress controller are running:
```bash
kubectl get nodes
kubectl get pods -n ingress-nginx
```

### 2. Install ArgoCD

```bash
cd ../demo_0

# Install mkcert and generate certificates
brew install mkcert
mkcert -install
mkcert argocd.local
mkdir -p certs
mv argocd.local*.pem certs/

# Install ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd -f argocd/values.yaml

# Configure SSL
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=certs/argocd.local.pem \
  --key=certs/argocd.local-key.pem

# Set up repository access
kubectl apply -f repos/repo.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 3. Run Demo 1 - Raw Manifests

```bash
cd ../demo_1
kubectl apply -f apps/demo_app.yaml

# Add to /etc/hosts
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts

# Access the application
open http://demo.local
```

### 4. Run Demo 2 - Helm Chart with OCI

```bash
cd ../demo_2

# Login to Docker Hub
helm registry login registry-1.docker.io

# Package and push chart
helm package golden_chart
helm push golden_chart-0.1.0.tgz oci://registry-1.docker.io/YOUR_USERNAME

# Update apps/demo_app.yaml with your Docker Hub username
# Then deploy
kubectl apply -f apps/demo_app.yaml

# Access the application
open http://demo.local
```

## Learning Path

### For Beginners
1. **Start with [Vanilla Kubernetes](vanila_kuberentes/README.md)** - Set up your local cluster
2. **Move to [Demo 0](demo_0/README.md)** - Install ArgoCD and understand the basics
3. **Try [Demo 1](demo_1/README.md)** - Learn GitOps workflow with raw manifests
4. **Skip Demo 2** initially - Come back after you're comfortable with Demo 1

### For Intermediate Users
1. **Review [Vanilla Kubernetes](vanila_kuberentes/README.md)** - Ensure you understand the cluster setup
2. **Quick install from [Demo 0](demo_0/README.md)** - Get ArgoCD running
3. **Explore [Demo 1](demo_1/README.md)** - Understand sync policies and self-healing
4. **Dive into [Demo 2](demo_2/README.md)** - Learn the Golden Chart pattern and multi-source apps

### For Advanced Users
1. **Set up everything** following the Quick Start above
2. **Focus on [Demo 2](demo_2/README.md)** - Study the Golden Chart pattern
3. **Experiment** with:
   - Creating multiple applications from the same chart
   - Building your own golden charts
   - Implementing environment-specific values
   - Setting up App of Apps pattern

## Key Concepts Covered

### GitOps Principles
- **Declarative**: Desired state defined in Git
- **Versioned**: All changes tracked in version control
- **Immutable**: Infrastructure changes through Git commits
- **Automated**: Continuous reconciliation of desired vs actual state

### ArgoCD Features
- Automated synchronization
- Self-healing capabilities
- Automatic pruning of deleted resources
- Multi-source applications
- Health assessment
- Sync waves and hooks

### Deployment Patterns
- **Direct Manifests**: Simple, straightforward (Demo 1)
- **Golden Charts**: Reusable templates with separated values (Demo 2)
- **Multi-Source**: Combining multiple Git/OCI sources (Demo 2)

## Architecture Comparison

| Aspect | Demo 1 | Demo 2 |
|--------|--------|--------|
| **Configuration** | Raw YAML files | Helm chart + values |
| **Reusability** | Copy/paste | Reusable template |
| **Source** | Single Git repo | Multi-source (OCI + Git) |
| **Flexibility** | Limited to manifests | Template variables |
| **Updates** | Edit each manifest | Change values only |
| **Versioning** | Git commits | Chart versions + Git |

## Common Commands

### Cluster Management
```bash
# List clusters
kind get clusters

# Delete cluster
kind delete cluster --name argocd-demo

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### ArgoCD Management
```bash
# Get applications
kubectl get applications -n argocd

# Delete application
kubectl delete application APPNAME -n argocd

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward to ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Application Management
```bash
# Watch pods
kubectl get pods -w

# View deployment
kubectl get deployment

# View ingress
kubectl get ingress

# Check application logs
kubectl logs -l app=demo
```

## Troubleshooting

### Cluster Issues
- **Port conflicts**: Check ports 80/443 are available (`sudo lsof -i :80`)
- **Docker not running**: Start Docker Desktop
- **Cluster not responding**: Delete and recreate cluster

### ArgoCD Issues
- **Can't access UI**: Check port-forward is running
- **Sync failures**: Check repository credentials and connectivity
- **Application not appearing**: Verify application manifest is correct

### Ingress Issues
- **Application not accessible**: Verify /etc/hosts entry exists
- **404 errors**: Check ingress resource is created (`kubectl get ingress`)
- **Connection refused**: Ensure ingress controller is running

## Repository Structure

```
.
├── README.md                    # This file
├── vanila_kuberentes/          # Foundation: Kind cluster setup
│   ├── kind-cluster.yaml       # Cluster configuration
│   ├── config.sh               # Ingress setup script
│   └── README.md
├── demo_0/                     # ArgoCD installation
│   ├── argocd/
│   │   └── values.yaml         # ArgoCD Helm values
│   ├── certs/                  # SSL certificates
│   ├── repos/
│   │   └── repo.yaml           # Git repository config
│   └── README.md
├── demo_1/                     # Raw manifests demo
│   ├── application_manifests/  # Kubernetes YAML files
│   ├── apps/
│   │   └── demo_app.yaml       # ArgoCD Application
│   └── README.md
└── demo_2/                     # Helm chart demo
    ├── golden_chart/           # Reusable Helm chart
    ├── application_values/     # Application-specific values
    ├── apps/
    │   └── demo_app.yaml       # ArgoCD Application
    └── README.md
```

## Additional Resources

### Documentation
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### GitOps Resources
- [GitOps Principles](https://opengitops.dev/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

### Related Topics
- ArgoCD ApplicationSets (for managing multiple apps)
- ArgoCD App of Apps pattern
- Sealed Secrets for sensitive data
- ArgoCD Rollouts for progressive delivery
- Multi-cluster deployments

## Contributing

To add more demos or improve existing ones:
1. Follow the established pattern (setup, prerequisites, step-by-step)
2. Test thoroughly with a fresh cluster
3. Update this main README with links and descriptions
4. Ensure cross-references between demos are accurate

## License

This demo series is for educational purposes.

## Support

For issues or questions:
1. Check the troubleshooting section in each demo's README
2. Review ArgoCD logs: `kubectl logs -n argocd deployment/argocd-server`
3. Verify cluster health: `kubectl get nodes` and `kubectl get pods -A`
