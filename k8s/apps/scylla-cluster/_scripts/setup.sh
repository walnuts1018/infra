#!/bin/bash
set -e

SCYLLA_PORT="${SCYLLA_PORT:-9142}"
MAX_RETRIES="${MAX_RETRIES:-60}" # 10分
RETRY_INTERVAL="${RETRY_INTERVAL:-10}"
ADMIN_CERTS_DIR="${ADMIN_CERTS_DIR:-/certs/admin}"
CA_CERTS_DIR="${CA_CERTS_DIR:-/certs/ca}"
KEYSPACES_CONFIG="${KEYSPACES_CONFIG:-/config/keyspaces.json}"
USERS_CONFIG="${USERS_CONFIG:-/config/users.json}"

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


create_keyspaces() {
    local cqlshrc="$1"
    
    echo "Creating keyspaces..."
    
    local keyspaces
    keyspaces=$(cat "${KEYSPACES_CONFIG}")

    echo "$keyspaces" | jq -c '.[]' | while read -r ks; do
        local name
        name=$(echo "$ks" | jq -r '.name')

        local replication
        replication=$(echo "$ks" | jq -rc '.replication')
        
        echo "Creating keyspace: ${name}"
        cqlsh --cqlshrc="${cqlshrc}" -e "
            CREATE KEYSPACE IF NOT EXISTS ${name}
            WITH replication = ${replication};
        "
    done
    
    echo "Keyspaces created successfully!"
}


create_users() {
    local cqlshrc="$1"
    
    echo "Creating users..."
    
    local users
    users=$(cat "${USERS_CONFIG}")
    
    echo "$users" | jq -c '.[]' | while read -r user; do
        local username
        username=$(echo "$user" | jq -r '.username')

        local password        
        password=$(echo "$user" | jq -r '.password')

        local superuser
        superuser=$(echo "$user" | jq -r '.superuser')

        local login
        login=$(echo "$user" | jq -r '.login')
        
        echo "Creating user: ${username} (superuser=${superuser}, login=${login})"
        
        cqlsh --cqlshrc="${cqlshrc}" -e "
            CREATE ROLE IF NOT EXISTS '${username}'
            WITH PASSWORD = '${password}'
            AND SUPERUSER = ${superuser}
            AND LOGIN = ${login};
        "
        
        # キースペース権限を付与
        local keyspace_perms
        keyspace_perms=$(echo "$user" | jq -r '.keyspace_permissions // empty')
        
        if [ -n "$keyspace_perms" ] && [ "$keyspace_perms" != "null" ]; then
            echo "$keyspace_perms" | jq -r '.[]' | while read -r ks; do
                echo "Granting permissions on keyspace ${ks} to ${username}"
                cqlsh --cqlshrc="${cqlshrc}" -e "
                    GRANT ALL PERMISSIONS ON KEYSPACE ${ks} TO '${username}';
                "
            done
        fi
    done
    
    echo "Users created successfully!"
}

log "info" "Preparing temporary directory..."
mkdir -p /tmp/cqlsh

log "info" "Starting ScyllaDB setup process"
setup_cqlshrc_config "/tmp/cqlsh/default.cqlshrc"

log "info" "Waiting for cluster..."
wait_for_cluster "/tmp/cqlsh/default.cqlshrc"

log "info" "Creating keyspaces..."
create_keyspaces "/tmp/cqlsh/default.cqlshrc"

log "info" "Creating users..."
create_users "/tmp/cqlsh/default.cqlshrc"

log "info" "Final verification..."
log "info" "Listing all roles:"
cqlsh --cqlshrc="/tmp/cqlsh/default.cqlshrc" -e "LIST ROLES;"

log "info" "Listing all keyspaces:"
cqlsh --cqlshrc="/tmp/cqlsh/default.cqlshrc" -e "DESCRIBE KEYSPACES;"

log "info" "ScyllaDB setup process completed successfully!"
