#!/bin/bash
set -e

SCYLLA_PORT="${SCYLLA_PORT:-9142}"
MAX_RETRIES="${MAX_RETRIES:-60}" # 10分
RETRY_INTERVAL="${RETRY_INTERVAL:-10}"
ADMIN_CERTS_DIR="${ADMIN_CERTS_DIR:-/certs/admin}"
CA_CERTS_DIR="${CA_CERTS_DIR:-/certs/ca}"
SCHEMA_FILE="${SCHEMA_FILE:-/config/migrations.cql}"
SCYLLA_ADMIN_USER="${SCYLLA_ADMIN_USER:-cassandra}"
SCYLLA_ADMIN_PASSWORD="${SCYLLA_ADMIN_PASSWORD:-cassandra}"

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

setup_cqlshrc_config() {
    local cqlshrc_path="$1"


    cat > "${cqlshrc_path}.credentials" <<EOF
[PlainTextAuthProvider]
username = ${SCYLLA_ADMIN_USER}
password = ${SCYLLA_ADMIN_PASSWORD}
EOF
    chmod 600 "${cqlshrc_path}.credentials"

    cat > "${cqlshrc_path}" <<EOF
[connection]
hostname = ${SCYLLA_HOST}
port = ${SCYLLA_PORT}
ssl = true
factory = cqlshlib.ssl.ssl_transport_factory

[ssl]
validate = true
certfile = /certs/ca/ca-bundle.crt
usercert = /certs/admin/tls.crt
userkey = /certs/admin/tls.key

[authentication]
credentials = ${cqlshrc_path}.credentials
EOF
}

wait_for_cluster() {
    local cqlshrc="$1"
    local retries=0

    log "info" "Waiting for ScyllaDB cluster to be ready..."
    
    while [ $retries -lt $MAX_RETRIES ]; do
    if cqlsh --cqlshrc="${cqlshrc}" -e "DESCRIBE CLUSTER" 2>/dev/null; then
        log "info" "ScyllaDB cluster is ready!"
        return 0
    fi
    
    retries=$((retries + 1))
    log "info" "Attempt ${retries}/${MAX_RETRIES}:  Cluster not ready yet.  Waiting ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
    done

    log "error" "Timeout waiting for ScyllaDB cluster"
    exit 1
}


migration() {
    local cqlshrc="$1"
    
    log "info" "Applying migrations from ${SCHEMA_FILE}..."
    cqlsh --cqlshrc="${cqlshrc}" -f "${SCHEMA_FILE}"
    log "info" "Migrations applied successfully."
}

log "info" "Preparing temporary directory..."
mkdir -p /tmp/cqlsh

log "info" "Starting ScyllaDB setup process"
setup_cqlshrc_config "/tmp/cqlsh/default.cqlshrc"

log "info" "Waiting for cluster..."
wait_for_cluster "/tmp/cqlsh/default.cqlshrc"

log "info" "Running migrations..."
migration "/tmp/cqlsh/default.cqlshrc"

log "info" "Final verification..."
log "info" "Listing all roles:"
cqlsh --cqlshrc="/tmp/cqlsh/default.cqlshrc" -e "LIST ROLES;"

log "info" "Listing all keyspaces:"
cqlsh --cqlshrc="/tmp/cqlsh/default.cqlshrc" -e "DESCRIBE KEYSPACES;"

log "info" "ScyllaDB setup process completed successfully!"
