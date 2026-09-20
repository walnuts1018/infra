#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: mise run argocd-agent:restart <cluster-context>" >&2
  exit 2
fi

kubectl --context "$1" -n argocd rollout restart deployment/argocd-agent
kubectl --context "$1" -n argocd rollout status deployment/argocd-agent --timeout=5m
