#!/usr/bin/bash

CLUSTER_NAME="longhorn-backup-validate"
NAMESPACE="longhorn-backup-validate"

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')
    
    shift 2
    local json="{\"level\":\"$level\",\"time\":\"$timestamp\",\"msg\":\"$msg\""
    while [[ $# -gt 0 ]]; do
        json+=",\"$1\":\"$2\""
        shift 2
    done
    echo "$json}"
}

log info "Waiting for cluster creation to complete" "cluster" "$CLUSTER_NAME"

START_TIME=$(date +%s)
END_TIME=$((START_TIME + 86400)) # Timeout: 24 hours

while [ "$(date +%s)" -lt $END_TIME ]; do
  if [ "$(kubectl get clusters.cluster.x-k8s.io -n "$NAMESPACE" "$CLUSTER_NAME" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')" == "True" ]; then
    log info "Cluster is ready" "cluster" "$CLUSTER_NAME"
    exit 0
  fi

  if [ "$(kubectl get clusters.cluster.x-k8s.io -n "$NAMESPACE" "$CLUSTER_NAME" -o jsonpath='{.status.phase}')" == "Failed" ]; then
    log error "Cluster creation failed" "cluster" "$CLUSTER_NAME"
    exit 1
  fi

  log info "Cluster is still being created... Checking again in 30 seconds." "cluster" "$CLUSTER_NAME"
  sleep 30
done

log error "Timed out waiting for Cluster '$CLUSTER_NAME' to become ready."
exit 1
