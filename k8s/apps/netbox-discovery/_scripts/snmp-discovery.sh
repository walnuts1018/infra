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

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

snmp_community_escaped="$(escape_sed_replacement "$SNMP_COMMUNITY")"
sed "s/\${SNMP_COMMUNITY}/$snmp_community_escaped/g" \
  /policies/snmp-policy.yaml > /tmp/snmp-policy.yaml

if ! wget -qO /tmp/snmp-policy-response \
  --header 'Content-Type: application/x-yaml' \
  --post-file /tmp/snmp-policy.yaml \
  http://127.0.0.1:8070/api/v1/policies; then
  cat /tmp/snmp-policy-response >&2 || true
  exit 1
fi
cat /tmp/snmp-policy-response

sleep 300
