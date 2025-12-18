#!/bin/bash

apt-get update
apt-get install -y \
    curl

curl -X POST \
    -H "Authorization: Bearer $(cat /var/run/secrets/shutdown-manager.local.walnuts.dev/serviceaccount/token)" \
    http://shutdown-manager.local.walnuts.dev/shutdown -v

echo "biscuit manager shutdown command sent"
