#!/bin/bash

curl -X POST \
    -H "Host: shutdown-manager.local.walnuts.dev" \
    -H "Authorization: Bearer $(cat /var/run/secrets/shutdown-manager.local.walnuts.dev/serviceaccount/token)" \
    http://192.168.0.158/shutdown -v

echo "biscuit manager shutdown command sent"
