#!/bin/bash

# constants
timeout=60*60*20 #20時間
lycoris_ip=192.168.0.12

mkdir -p /samba-backup

# install dependency
apt-get update
apt-get install rsync ssh samba-client cifs-utils -y

# Lycorisが起動するまで待つ
now=$(date +%s)
end=$(($now + $timeout))
while [ $(date +%s) -lt $end ]; do
    mount -t cifs -o user=$SAMBA_USER,password=$SAMBA_PASSWORD,uid=1000,gid=1000,file_mode=0755,dir_mode=0755 //$lycoris_ip/f /samba-backup
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 60 #[s]
done

if [ $(date +%s) -ge $end ]; then
    echo "Lycoris did not start"
    exit 1
fi

# samba-backupをマウント

# for k8s liveness probe
touch /tmp/healthy

# Lycorisが起動したらrsyncでバックアップを取る
DISTDIR="/samba-backup"
LATEST_BACKUP_DIR=$(ls -d $DISTDIR/*/ | grep "/backup-" | tail -n 1)
echo "Latest backup dir: $LATEST_BACKUP_DIR"

DATE_SUFFIX=$(date +%Y-%m-%d_%Hh%Mm%Ss)
DATEDIR="$DISTDIR/tmp-backup-$DATE_SUFFIX"
echo "New backup dir: $DATEDIR"

mkdir $DATEDIR

#rsync -avh --link-dest="$LATEST_BACKUP_DIR" --exclude='$RECYCLE.BIN' --exclude="longhorn" /samba-share/ "$DATEDIR"
rsync -rltDvh --link-dest="$LATEST_BACKUP_DIR" --exclude='$RECYCLE.BIN' --exclude="longhorn" /samba-share/ "$DATEDIR" # NTFSだと権限が正しくコピーされず、リンクが張れないので-pgoを使わない

if [ $? -ne 0 ]; then
    echo "rsync failed"
    exit 1
fi

mv $DATEDIR $DISTDIR/backup-$DATE_SUFFIX
