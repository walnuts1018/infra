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


log "info" "Starting Longhorn backup validation process"

sleep infinity # TODO
