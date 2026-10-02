#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s dotglob nullglob

source=/source
target=/target
marker="$target/.infra-linux-desktop-bootstrap-v1"
lock="$target/.infra-linux-desktop-bootstrap.lock"
lock_owned=false
mounted_paths=()

if [[ -e "$marker" ]]; then
  echo 'Root filesystem is already bootstrapped; leaving it unchanged.'
  exit 0
fi

[[ -d "$source" ]] || { echo 'Root filesystem image volume is missing.' >&2; exit 1; }
[[ -d "$target" ]] || { echo 'Root filesystem PVC is missing.' >&2; exit 1; }
[[ ! -e "$source/.infra-linux-desktop-bootstrap-v1" ]] || {
  echo 'The source image contains the reserved bootstrap marker.' >&2
  exit 1
}

if ! mkdir "$lock"; then
  echo 'Another bootstrap process or a stale bootstrap lock exists.' >&2
  exit 1
fi
lock_owned=true

cleanup_mounts() {
  local failed=0
  local index
  for ((index = ${#mounted_paths[@]} - 1; index >= 0; index--)); do
    umount -R "${mounted_paths[index]}" || failed=1
  done
  mounted_paths=()
  return "$failed"
}

cleanup() {
  local status=$?
  trap - EXIT
  if ((${#mounted_paths[@]} > 0)); then
    cleanup_mounts || true
  fi
  if [[ "$lock_owned" == true ]]; then
    rmdir "$lock" 2>/dev/null || true
  fi
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ -e "$marker" ]]; then
  echo 'Root filesystem is already bootstrapped; leaving it unchanged.'
  exit 0
fi

for entry in "$target"/*; do
  name=${entry##*/}
  if [[ "$name" == '.infra-linux-desktop-bootstrap.lock' ]]; then
    continue
  fi
  if [[ "$name" == 'lost+found' && -d "$entry" && ! -L "$entry" ]] &&
    [[ -z "$(find "$entry" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    continue
  fi
  printf 'Refusing to initialize a non-empty root filesystem PVC: %s\n' "$entry" >&2
  exit 1
done

cp -a --preserve=all -- "$source/." "$target/"

for path in etc usr var home root opt srv proc sys dev run tmp; do
  [[ -d "$target/$path" ]] || {
    printf 'Copied root filesystem is missing /%s.\n' "$path" >&2
    exit 1
  }
done
[[ -x "$target/init" || -x "$target/usr/bin/bash" ]] || {
  echo 'Copied root filesystem has no executable init or bash.' >&2
  exit 1
}

bind_tree() {
  local source_path=$1
  local target_path=$2
  mount --rbind "$source_path" "$target_path"
  mounted_paths+=("$target_path")
  mount --make-rslave "$target_path"
}

bind_file() {
  local source_path=$1
  local target_path=$2
  mount --bind "$source_path" "$target_path"
  mounted_paths+=("$target_path")
}

mount --make-rprivate /
bind_tree /proc "$target/proc"
bind_tree /sys "$target/sys"
bind_tree /dev "$target/dev"
bind_tree /run "$target/run"
bind_tree /tmp "$target/tmp"
mkdir -p "$target/run/infra-bootstrap"
mount --bind /scripts "$target/run/infra-bootstrap"
mounted_paths+=("$target/run/infra-bootstrap")

for name in resolv.conf hosts hostname; do
  [[ -e "/etc/$name" ]] || {
    printf 'Kubernetes-provided /etc/%s is missing.\n' "$name" >&2
    exit 1
  }
  [[ -e "$target/etc/$name" ]] || : > "$target/etc/$name"
  bind_file "/etc/$name" "$target/etc/$name"
done

chroot "$target" /usr/bin/bash /run/infra-bootstrap/configure-rootfs.sh
cleanup_mounts
sync

marker_tmp="$target/.infra-linux-desktop-bootstrap-v1.$$"
{
  printf 'source_image=%s\n' "$ROOTFS_IMAGE_REFERENCE"
  printf 'bootstrap_timestamp_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$marker_tmp"
chmod 0444 "$marker_tmp"
sync
mv -- "$marker_tmp" "$marker"
sync

echo 'Root filesystem bootstrap completed.'
