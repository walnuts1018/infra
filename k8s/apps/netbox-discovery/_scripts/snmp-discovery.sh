#!/bin/sh
set -eu

snmp-discovery \
  -host 127.0.0.1 \
  -port 8070 \
  -diode-target 'grpc://diode-gateway.netbox.svc.cluster.local/diode' \
  -diode-client-id '${DIODE_CLIENT_ID}' \
  -diode-client-secret '${DIODE_CLIENT_SECRET}' \
  -diode-app-name-prefix 'netbox-discovery' \
  -log-format JSON &
pid="$!"
trap 'kill "$pid" 2>/dev/null || true' EXIT

for _ in $(seq 1 60); do
  if wget -qO- http://127.0.0.1:8070/api/v1/status >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

wget -qO- \
  --header 'Content-Type: application/x-yaml' \
  --post-file /policies/snmp-policy.yaml \
  http://127.0.0.1:8070/api/v1/policies

sleep 300
