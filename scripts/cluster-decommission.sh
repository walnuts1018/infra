#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: mise run cluster:decommission <cluster-name>" >&2
  exit 2
fi

cluster_context="$1"
repo_root=$(git rev-parse --show-toplevel)
cluster_descriptor="${repo_root}/k8s/clusters/${cluster_context}/cluster.json5"

if [[ -e "${cluster_descriptor}" ]]; then
  echo "remove and commit ${cluster_descriptor} before decommissioning ${cluster_context}" >&2
  exit 1
fi

remaining_app_descriptors=$(rg -l -U "^[[:space:]]+${cluster_context}[[:space:]]*:" "${repo_root}"/k8s/apps/*/app.json5 || true)
if [[ -n "${remaining_app_descriptors}" ]]; then
  echo "remove ${cluster_context} from these app descriptors before decommissioning ${cluster_context}:" >&2
  echo "${remaining_app_descriptors}" >&2
  exit 1
fi

# The checks above only look at the local working tree. berry's ApplicationSets
# still read the last pushed commit, so an uncommitted or unpushed removal
# wouldn't actually stop them from regenerating the Applications we're about
# to delete below.
if [[ -n "$(git -C "${repo_root}" status --porcelain)" ]]; then
  echo "working tree has uncommitted changes; commit and push before decommissioning ${cluster_context}" >&2
  exit 1
fi

current_branch=$(git -C "${repo_root}" rev-parse --abbrev-ref HEAD)
git -C "${repo_root}" fetch origin "${current_branch}" --quiet
if [[ "$(git -C "${repo_root}" rev-parse HEAD)" != "$(git -C "${repo_root}" rev-parse "origin/${current_branch}")" ]]; then
  echo "HEAD is not pushed to origin/${current_branch}; push before decommissioning ${cluster_context}" >&2
  exit 1
fi

# The ApplicationSet must no longer generate this Application. Orphaning it
# keeps the cleanup below explicit and prevents Argo CD from pruning workload
# resources as a side effect of deleting the parent Application.
kubectl --context berry -n argocd delete application "${cluster_context}" --cascade=orphan --ignore-not-found

# Remove generated Applications that still target the cluster. Orphaning keeps
# workload resources in place while the cluster bootstrap resources are removed.
workload_applications=$(kubectl --context berry -n argocd get applications -o json \
  | jq -r --arg cluster "${cluster_context}" '.items[] | select(.spec.destination.name == $cluster) | .metadata.name')
while IFS= read -r application; do
  [[ -z "${application}" ]] && continue
  kubectl --context berry -n argocd delete application "${application}" --cascade=orphan --ignore-not-found
done <<<"${workload_applications}"

kubectl --context berry -n "$cluster_context" delete helmchartproxy cilium-bootstrap argocd-spoke argocd-agent --ignore-not-found
kubectl --context berry -n "$cluster_context" delete clusterresourceset argocd-agent --ignore-not-found
kubectl --context berry -n "$cluster_context" delete externalsecret argocd-agent-resources --ignore-not-found
kubectl --context berry -n "$cluster_context" delete secret argocd-agent-resources --ignore-not-found
kubectl --context berry delete clustersecretstore "argocd-agent-${cluster_context}" --ignore-not-found
kubectl --context berry -n argocd delete rolebinding "argocd-agent-secret-reader-${cluster_context}" --ignore-not-found
kubectl --context berry -n argocd delete role "argocd-agent-secret-reader-${cluster_context}" --ignore-not-found
kubectl --context berry -n argocd delete serviceaccount "argocd-agent-secret-reader-${cluster_context}" --ignore-not-found
kubectl --context berry -n argocd delete secret "cluster-$cluster_context" --ignore-not-found
kubectl --context berry -n "$cluster_context" delete cluster "$cluster_context" --ignore-not-found
