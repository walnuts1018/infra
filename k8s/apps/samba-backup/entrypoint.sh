#!/bin/bash

timeout=60*60*12 #12時間
alice_ip=root@192.168.0.11

sudo chmod 600 /root/.ssh/id_ed25519

# aliceが起動するまで待つ
now=$(date +%s)
end=$(($now + $timeout))
while [ $(date +%s) -lt $end ]; do
    ssh $alice_ip exit
    if [ $? -eq 0 ]; then
        break
    fi
done

if [ $(date +%s) -ge $end ]; then
    echo "alice did not start"
    exit 1
fi

# aliceが起動したらrsyncでバックアップを取る
DISTDIR="/mnt/HDD1TB/smb-backup"
LATEST_BACKUP_DIR=$(ssh $alice_ip "ls -d $DISTDIR/*/ | grep "/backup-" | tail -n 1")
echo "Latest backup dir: $LATEST_BACKUP_DIR"

DATE_SUFFIX=$(date +%Y-%m-%d_%Hh%Mm%Ss)
DATEDIR="$DISTDIR/tmp-backup-$DATE_SUFFIX"
echo "New backup dir: $DATEDIR"

mkdir $DATEDIR
rsync -avh --link-dest="$LATEST_BACKUP_DIR" --exclude='$RECYCLE.BIN' /samba-share "$alice_ip:$DATEDIR"

if [ $? -ne 0 ]; then
    echo "rsync failed"
    exit 1
fi

ssh $alice_ip "mv $DATEDIR $DISTDIR/backup-$DATE_SUFFIX"