# Use dockerhub as a helm repo

Login into repo: `helm registry login registry-1.docker.io`
Create helm package: `helm package golden_chart`
Push the chart: `helm push golden_chart-0.1.0.tgz oci://registry-1.docker.io/mateuszwocka`

## Add repo into ArgoCD

Add it manually.

