#!/usr/bin/bash


CRONJOB_NAME="minio-biscuit-backup"
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

kubectl() {
  command kubectl \
    --server=https://192.168.0.15:6443 \
    --token="$(cat /var/run/secrets/kurumi.k8s.walnuts.dev/serviceaccount/token)" \
    --insecure-skip-tls-verify=true \
    "$@"
}

START_TIME=$(date +%s)

JOB_NAME="$CRONJOB_NAME-manual-$START_TIME"

kubectl create job --from=cronjob/$CRONJOB_NAME "$JOB_NAME" -n $NAMESPACE || {
  log "error" "Failed to create Job from CronJob" "cronjob" "$CRONJOB_NAME"
  exit 1
}

log "info" "Waiting..." "job" "$JOB_NAME"

END_TIME=$((START_TIME + 86400)) # Timeout: 24 hours

while [ "$(date +%s)" -lt $END_TIME ]; do
  if [ "$(kubectl get job -n "$NAMESPACE" "$JOB_NAME" -o jsonpath='{.status.succeeded}')" == "1" ]; then
    log "info" "Job completed successfully" "job" "$JOB_NAME"
    exit 0
  fi

  if [ "$(kubectl get job -n "$NAMESPACE" "$JOB_NAME" -o jsonpath='{.status.failed}')" == "1" ]; then
    log "error" "Job failed" "job" "$JOB_NAME"
    exit 1
  fi

  log "info" "Job is still running... Checking again in 30 seconds." "job" "$JOB_NAME"
  sleep 30
done

log "error" "Timed out waiting for Job to complete." "job" "$JOB_NAME"
exit 1
