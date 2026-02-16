#!/usr/bin/bash

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


log "info" "Starting backup process"

EXCLUDE_ARGS=()
for BUCKET in $(rclone lsf minio-default: --dirs-only --config=/config/rclone.conf | sed 's/\///g'); do
    if aws s3api get-bucket-tagging --profile minio-default --bucket "${BUCKET}" 2>/dev/null | jq -e '.TagSet[] | select(.Key == "skip-backup")' > /dev/null; then
        log "info" "Excluding bucket due to skip-backup tag" bucket "${BUCKET}"
        EXCLUDE_ARGS+=("--exclude" "/${BUCKET}/**")
    else
        log "info" "Including bucket in sync" bucket "${BUCKET}"
    fi
done

SOURCE_PATH="minio-default:"
DEST_PATH="minio-biscuit:minio-default-backup/"

log "info" "Sync started" source "${SOURCE_PATH}" dest "${DEST_PATH}"

rclone sync --metrics-addr=:9250 --config=/config/rclone.conf -v \
    "${SOURCE_PATH}" "${DEST_PATH}" "${EXCLUDE_ARGS[@]}"

if [[ $? -eq 0 ]]; then
    log "info" "Sync completed successfully" source "${SOURCE_PATH}" dest "${DEST_PATH}"
    log "info" "Backup process completed successfully"
else
    log "error" "Sync failed" source "${SOURCE_PATH}" dest "${DEST_PATH}"
    log "error" "Backup process completed with errors"
    exit 1
fi
