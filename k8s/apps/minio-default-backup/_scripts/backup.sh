#!/bin/ash
# shellcheck shell=dash

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')
    
    shift 2
    local json="{\"level\":\"$level\",\"time\":$timestamp,\"msg\":\"$msg\""
    while [ $# -gt 0 ]; do
        json="$json,\"$1\":\"$2\""
        shift 2
    done
    echo "$json}"
}


log "info" "Starting backup process"

for BUCKET in $(rclone lsf minio-default: --dirs-only --config=/config/rclone.conf | sed 's/\///g'); do
    SOURCE_PATH="minio-default:${BUCKET}"
    DEST_PATH="minio-biscuit:minio-default-backup/${BUCKET}"
    log "info" "Sync started" source="${SOURCE_PATH}" dest="${DEST_PATH}"
    rclone sync --config=/config/rclone.conf -v "${SOURCE_PATH}" "${DEST_PATH}"
    if [ $? -eq 0 ]; then
        log "info" "Sync completed successfully" source="${SOURCE_PATH}" dest="${DEST_PATH}"
    else
        log "error" "Sync failed" source="${SOURCE_PATH}" dest="${DEST_PATH}"
    fi
done

log "info" "Backup process completed"
