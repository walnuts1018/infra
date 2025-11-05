#!/usr/bin/bash

CRONJOB_NAME="minio-default-backup"
NAMESPACE="minio"

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')
    
    shift 2
    local json="{\"level\":\"$level\",\"time\":$timestamp,\"msg\":\"$msg\""
    while [[ $# -gt 0 ]]; do
        json+=",\"$1\":\"$2\""
        shift 2
    done
    echo "$json}"
}

LATEST_JOB_NAME=$(kubectl get jobs -n "$NAMESPACE" \
  -l "app.kubernetes.io/name=$CRONJOB_NAME" \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.name}')

if [ -z "$LATEST_JOB_NAME" ]; then
  log "error" "No jobs found for CronJob" cronjob "$CRONJOB_NAME"
  exit 1
fi

log info "Waiting..." "job" "$LATEST_JOB_NAME"

START_TIME=$(date +%s)
END_TIME=$((START_TIME + 86400)) # Timeout: 24 hours

while [ "$(date +%s)" -lt $END_TIME ]; do
  if [ "$(kubectl get job -n "$NAMESPACE" "$LATEST_JOB_NAME" -o jsonpath='{.status.succeeded}')" == "1" ]; then
    log info "Job completed successfully" "job" "$LATEST_JOB_NAME"
    exit 0
  fi

  if [ "$(kubectl get job -n "$NAMESPACE" "$LATEST_JOB_NAME" -o jsonpath='{.status.failed}')" == "1" ]; then
    log error "Job failed" "job" "$LATEST_JOB_NAME"
    exit 1
  fi

  log info "Job is still running... Checking again in 30 seconds." "job" "$LATEST_JOB_NAME"
  sleep 30
done

log error "Timed out waiting for Job '$LATEST_JOB_NAME' to complete."
exit 1
