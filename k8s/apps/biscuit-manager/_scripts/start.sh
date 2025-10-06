#!/bin/bash

timeout=$((60*10)) #10分
interval=20 #[s]
biscuit_ip=192.168.0.15
biscuit_mac=18:03:73:e4:b9:e7

apt-get update
apt-get install -y \
    wakeonlan

wakeonlan $biscuit_mac

# 起動するまで待つ
now=$(date +%s)
end=$(($now + $timeout))
while [ "$(date +%s)" -lt "$end" ]; do
    ping -c 1 $biscuit_ip > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
    sleep $interval 
done

echo "biscuit manager started"
