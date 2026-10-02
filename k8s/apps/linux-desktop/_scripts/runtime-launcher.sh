#!/usr/bin/env bash
set -Eeuo pipefail

sysroot=/sysroot
marker="$sysroot/.infra-linux-desktop-bootstrap-v1"

if [[ ! -f "$marker" ]]; then
  echo 'Root filesystem bootstrap marker is missing; refusing to start the desktop.' >&2
  exit 1
fi

mount --make-rprivate /

bind_tree() {
  local source_path=$1
  local target_path=$2
  mount --rbind "$source_path" "$target_path"
  mount --make-rslave "$target_path"
}

bind_tree /proc "$sysroot/proc"
bind_tree /sys "$sysroot/sys"
bind_tree /dev "$sysroot/dev"
bind_tree /run "$sysroot/run"
bind_tree /tmp "$sysroot/tmp"

mkdir -p "$sysroot/run/linux-desktop-launcher"
mount --bind /launcher "$sysroot/run/linux-desktop-launcher"

for name in resolv.conf hosts hostname; do
  if [[ ! -e "/etc/$name" ]]; then
    printf 'Kubernetes-provided /etc/%s is missing.\n' "$name" >&2
    exit 1
  fi
  if [[ ! -e "$sysroot/etc/$name" ]]; then
    : > "$sysroot/etc/$name"
  fi
  mount --bind "/etc/$name" "$sysroot/etc/$name"
done

exec chroot "$sysroot" /usr/bin/bash /run/linux-desktop-launcher/session.sh
