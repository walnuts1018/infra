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

python -c 'import os
policy = open("/policies/snmp-policy.yaml").read()
for key in ("SNMP_COMMUNITY",):
    policy = policy.replace("${" + key + "}", os.environ[key])
open("/tmp/snmp-policy.yaml", "w").write(policy)'

python -c 'import sys, urllib.error, urllib.request
data = open("/tmp/snmp-policy.yaml", "rb").read()
req = urllib.request.Request(
    "http://127.0.0.1:8070/api/v1/policies",
    data=data,
    headers={"Content-Type": "application/x-yaml"},
    method="POST",
)
try:
    print(urllib.request.urlopen(req, timeout=30).read().decode())
except urllib.error.HTTPError as exc:
    sys.stderr.write(exc.read().decode(errors="replace"))
    raise'

sleep 300
