#!/bin/sh
set -eu

device-discovery \
  -s 127.0.0.1 \
  -p 8072 \
  -t 'grpc://diode-gateway.netbox.svc.cluster.local/diode' \
  -c '${DIODE_CLIENT_ID}' \
  -k '${DIODE_CLIENT_SECRET}' \
  -a 'netbox-discovery' &
pid="$!"
trap 'kill "$pid" 2>/dev/null || true' EXIT

python -c 'import time, urllib.request
url = "http://127.0.0.1:8072/api/v1/status"
for _ in range(60):
    try:
        urllib.request.urlopen(url, timeout=2).read()
        break
    except Exception:
        time.sleep(1)
else:
    raise SystemExit("device-discovery did not become ready")'

python -c 'import os
policy = open("/policies/device-policy.yaml").read()
for key in ("NAPALM_USERNAME", "NAPALM_PASSWORD"):
    policy = policy.replace("${" + key + "}", os.environ[key])
open("/tmp/device-policy.yaml", "w").write(policy)'

python -c 'import urllib.request
data = open("/tmp/device-policy.yaml", "rb").read()
req = urllib.request.Request(
    "http://127.0.0.1:8072/api/v1/policies",
    data=data,
    headers={"Content-Type": "application/x-yaml"},
    method="POST",
)
print(urllib.request.urlopen(req, timeout=10).read().decode())'

sleep 300
