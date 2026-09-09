#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 || "$1" != "biscuit" ]]; then
  echo "usage: mise run cluster:decommission biscuit" >&2
  exit 2
fi

cluster_context="$1"

kubectl --context berry -n "$cluster_context" delete helmchartproxy argocd-spoke argocd-agent --ignore-not-found
kubectl --context berry -n "$cluster_context" delete clusterresourceset argocd-agent --ignore-not-found
kubectl --context berry -n "$cluster_context" delete externalsecret argocd-agent-resources --ignore-not-found
kubectl --context berry -n "$cluster_context" delete secret argocd-agent-resources --ignore-not-found
kubectl --context berry delete clustersecretstore argocd-agent-berry --ignore-not-found
kubectl --context berry -n argocd delete rolebinding argocd-agent-secret-reader --ignore-not-found
kubectl --context berry -n argocd delete role argocd-agent-secret-reader --ignore-not-found
kubectl --context berry -n argocd delete serviceaccount argocd-agent-secret-reader --ignore-not-found
kubectl --context berry -n argocd delete secret "cluster-$cluster_context" --ignore-not-found
kubectl --context berry -n "$cluster_context" delete cluster "$cluster_context" --ignore-not-found
