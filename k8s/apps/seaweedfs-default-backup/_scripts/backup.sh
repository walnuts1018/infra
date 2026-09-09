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
tagging_error_file=$(mktemp)
trap 'rm -f "$tagging_error_file"' EXIT
for BUCKET in $(rclone lsf seaweedfs-default: --dirs-only --config=/config/rclone.conf | sed 's/\///g'); do
    : >"${tagging_error_file}"
    if tagging=$(aws s3api get-bucket-tagging --profile seaweedfs-default --bucket "${BUCKET}" 2>"${tagging_error_file}"); then
        if jq -e '.TagSet[]? | select(.Key == "skip-backup")' <<<"${tagging}" > /dev/null; then
            log "info" "Excluding bucket due to skip-backup tag" bucket "${BUCKET}"
            EXCLUDE_ARGS+=("--exclude" "/${BUCKET}/**")
        else
            log "info" "Including bucket in sync" bucket "${BUCKET}"
        fi
    elif grep -Eq 'NoSuchTagSet|NoSuchTag' "${tagging_error_file}"; then
        log "info" "Including bucket without tags" bucket "${BUCKET}"
    else
        log "error" "Failed to read bucket tags" bucket "${BUCKET}" error "$(<"${tagging_error_file}")"
        exit 1
    fi
done

SOURCE_PATH="seaweedfs-default:"
DEST_PATH="seaweedfs-biscuit:seaweedfs-default-backup/"

log "info" "Sync started" source "${SOURCE_PATH}" dest "${DEST_PATH}"

if rclone copy --metrics-addr=:9250 --config=/config/rclone.conf -v \
    "${SOURCE_PATH}" "${DEST_PATH}" "${EXCLUDE_ARGS[@]}"; then
    log "info" "Sync completed successfully" source "${SOURCE_PATH}" dest "${DEST_PATH}"
else
    log "error" "Sync failed" source "${SOURCE_PATH}" dest "${DEST_PATH}"
    log "error" "Backup process completed with errors"
    exit 1
fi

B2_PATH="b2:walnuts-seaweedfs-biscuit-backup-81f18e5/"
log "info" "Offsite backup started" source "${DEST_PATH}" dest "${B2_PATH}"
if rclone copy --metrics-addr=:9250 --config=/config/rclone.conf -v \
    "${DEST_PATH}" "${B2_PATH}"; then
    log "info" "Offsite backup completed" source "${DEST_PATH}" dest "${B2_PATH}"
else
    log "error" "Offsite backup failed" source "${DEST_PATH}" dest "${B2_PATH}"
    exit 1
fi
log "info" "Backup process completed successfully"
