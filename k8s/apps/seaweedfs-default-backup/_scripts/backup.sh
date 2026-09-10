#!/usr/bin/bash

set -euo pipefail

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')

    shift 2
    local -a jq_args=(--arg level "$level" --arg time "$timestamp" --arg msg "$msg")
    local json_expression='{level:$level,time:$time,msg:$msg}'
    local field_index=0
    while [[ $# -gt 0 ]]; do
        jq_args+=(--arg "key${field_index}" "$1" --arg "value${field_index}" "$2")
        json_expression+=" | .[\$key${field_index}] = \$value${field_index}"
        shift 2
        ((field_index += 1))
    done
    jq -cn "${jq_args[@]}" "$json_expression"
}


log "info" "Starting backup process"

BACKUP_BUCKETS=()
tagging_error_file=$(mktemp)
trap 'rm -f "$tagging_error_file"' EXIT
if ! bucket_list="$(rclone lsf seaweedfs-default: --dirs-only --config=/config/rclone.conf | sed 's/\///g')"; then
    log "error" "Failed to list source buckets"
    exit 1
fi

while IFS= read -r BUCKET; do
    [[ -z "${BUCKET}" ]] && continue
    : >"${tagging_error_file}"
    if tagging=$(aws s3api get-bucket-tagging --profile seaweedfs-default --bucket "${BUCKET}" 2>"${tagging_error_file}"); then
        if jq -e '.TagSet[]? | select(.Key == "skip-backup")' <<<"${tagging}" > /dev/null; then
            log "info" "Excluding bucket due to skip-backup tag" bucket "${BUCKET}"
        else
            log "info" "Including bucket in sync" bucket "${BUCKET}"
            BACKUP_BUCKETS+=("${BUCKET}")
        fi
    elif grep -Eq 'NoSuchTagSet|NoSuchTag' "${tagging_error_file}"; then
        log "info" "Including bucket without tags" bucket "${BUCKET}"
        BACKUP_BUCKETS+=("${BUCKET}")
    else
        log "error" "Failed to read bucket tags" bucket "${BUCKET}" error "$(<"${tagging_error_file}")"
        exit 1
    fi
done <<<"${bucket_list}"

for BUCKET in "${BACKUP_BUCKETS[@]}"; do
    SOURCE_PATH="seaweedfs-default:${BUCKET}/"
    DEST_PATH="seaweedfs-biscuit:seaweedfs-default-backup/${BUCKET}/"
    log "info" "Sync started" source "${SOURCE_PATH}" dest "${DEST_PATH}" bucket "${BUCKET}"

    if rclone sync --metrics-addr=:9250 --config=/config/rclone.conf -v \
        "${SOURCE_PATH}" "${DEST_PATH}"; then
        log "info" "Sync completed successfully" source "${SOURCE_PATH}" dest "${DEST_PATH}" bucket "${BUCKET}"
    else
        log "error" "Sync failed" source "${SOURCE_PATH}" dest "${DEST_PATH}" bucket "${BUCKET}"
        log "error" "Backup process completed with errors"
        exit 1
    fi
done

for BUCKET in "${BACKUP_BUCKETS[@]}"; do
    SOURCE_PATH="seaweedfs-biscuit:seaweedfs-default-backup/${BUCKET}/"
    B2_PATH="b2:walnuts-seaweedfs-biscuit-backup-81f18e5/${BUCKET}/"
    log "info" "Offsite backup started" source "${SOURCE_PATH}" dest "${B2_PATH}" bucket "${BUCKET}"
    if rclone sync --metrics-addr=:9250 --config=/config/rclone.conf -v \
        "${SOURCE_PATH}" "${B2_PATH}"; then
        log "info" "Offsite backup completed" source "${SOURCE_PATH}" dest "${B2_PATH}" bucket "${BUCKET}"
    else
        log "error" "Offsite backup failed" source "${SOURCE_PATH}" dest "${B2_PATH}" bucket "${BUCKET}"
        exit 1
    fi
done
log "info" "Backup process completed successfully"
