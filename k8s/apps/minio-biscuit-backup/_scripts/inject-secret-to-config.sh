#!/usr/bin/bash

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


log "info" "Starting rclone congig generation"

TEMPLATE_FILE="$1"
OUTPUT_FILE="$2"


B2_ENCRYPTED_PASSWORD_OBSCURED=$(rclone obscure "$B2_ENCRYPTED_PASSWORD")
export B2_ENCRYPTED_PASSWORD_OBSCURED
B2_ENCRYPTED_SALT_OBSCURED=$(rclone obscure "$B2_ENCRYPTED_HASH")
export B2_ENCRYPTED_SALT_OBSCURED

envsubst < "${TEMPLATE_FILE}" > "${OUTPUT_FILE}"
