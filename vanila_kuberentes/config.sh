#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl patch deployment ingress-nginx-controller \
  -n ingress-nginx \
  --type=json \
  -p='[
    {"op":"add","path":"/spec/template/spec/nodeSelector","value":{"ingress-ready":"true"}},
    {"op":"add","path":"/spec/template/spec/tolerations","value":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}
  ]'

kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
