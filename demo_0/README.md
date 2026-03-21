# Notes

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd -f argocd/values.yaml

## Post actions

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

## Cert

brew install mkcert
mkcert -install
mkcert argocd.local

## Turn on SSL

kubectl create -n argocd secret tls argocd-server-tls \
  --cert=certs/argocd.local.pem \
  --key=certs/argocd.local-key.pem