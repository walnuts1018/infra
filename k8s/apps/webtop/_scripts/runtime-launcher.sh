#!/usr/bin/env bash
set -Eeuo pipefail

sysroot=/sysroot
marker="$sysroot/.infra-webtop-bootstrap-v1"

if [[ ! -f "$marker" ]]; then
  echo 'Webtop root filesystem bootstrap marker is missing; refusing to start.' >&2
  exit 1
fi
[[ -x "$sysroot/init" ]] || {
  echo 'Webtop root filesystem has no executable /init.' >&2
  exit 1
}

mount --make-rprivate /

bind_tree() {
  local source_path=$1
  local target_path=$2
  [[ -d "$target_path" ]] || {
    printf 'Webtop root filesystem is missing mountpoint %s.\n' "$target_path" >&2
    exit 1
  }
  mount --rbind "$source_path" "$target_path"
  mount --make-rslave "$target_path"
}

bind_tree /proc "$sysroot/proc"
bind_tree /sys "$sysroot/sys"
bind_tree /dev "$sysroot/dev"
bind_tree /run "$sysroot/run"
bind_tree /tmp "$sysroot/tmp"

mkdir -p "$sysroot/run/infra-webtop-launcher"
mount --bind /launcher "$sysroot/run/infra-webtop-launcher"

for name in resolv.conf hosts hostname; do
  source_path="/etc/$name"
  target_path="$sysroot/etc/$name"
  [[ -e "$source_path" ]] || {
    printf 'Kubernetes-provided %s is missing.\n' "$source_path" >&2
    exit 1
  }
  if [[ -L "$target_path" ]]; then
    rm -- "$target_path"
  fi
  [[ -e "$target_path" ]] || : > "$target_path"
  mount --bind "$source_path" "$target_path"
done

exec /usr/sbin/chroot "$sysroot" /init
