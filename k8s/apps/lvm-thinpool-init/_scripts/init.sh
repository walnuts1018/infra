set -eu
apk add --no-cache lvm2 xfsprogs util-linux e2fsprogs >/dev/null

# VGがまだ来ていない(TartHostのdisk provisioningが終わっていない)場合は待つ。
until vgs data >/dev/null 2>&1; do
  echo "waiting for VG 'data' to appear..."
  sleep 5
done

if ! lvs data/pool0 >/dev/null 2>&1; then
  echo "creating thin-pool data/pool0"
  lvcreate --type thinpool -l 90%FREE -n pool0 data
fi

if ! lvs data/lv-longhorn >/dev/null 2>&1; then
  echo "creating thin LV data/lv-longhorn (${LONGHORN_LV_SIZE_GIB}GiB virtual)"
  lvcreate -V "${LONGHORN_LV_SIZE_GIB}GiB" --thin -n lv-longhorn data/pool0
  mkfs.xfs /dev/data/lv-longhorn
fi

mkdir -p /mnt/longhorn
if ! mountpoint -q /mnt/longhorn; then
  mount /dev/data/lv-longhorn /mnt/longhorn
fi

echo "done, sleeping"
sleep infinity
