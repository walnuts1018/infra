#!/usr/bin/env bash
set -Eeuo pipefail

export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WLR_RENDERER=pixman
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway

sway &
sway_pid=$!
wayvnc_pid=

cleanup() {
  local status=$?
  trap - EXIT INT TERM
  if [[ -n "$wayvnc_pid" ]]; then
    kill "$wayvnc_pid" 2>/dev/null || true
  fi
  kill "$sway_pid" 2>/dev/null || true
  wait "$wayvnc_pid" 2>/dev/null || true
  wait "$sway_pid" 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

wayland_display=
for attempt in $(seq 1 300); do
  if ! kill -0 "$sway_pid" 2>/dev/null; then
    wait "$sway_pid"
  fi
  for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
    if [[ -S "$socket" ]]; then
      wayland_display=${socket##*/}
      break
    fi
  done
  [[ -n "$wayland_display" ]] && break
  sleep 0.2
done

if [[ -z "$wayland_display" ]]; then
  echo 'Sway did not create a Wayland socket within 60 seconds.' >&2
  exit 1
fi

export WAYLAND_DISPLAY="$wayland_display"
wayvnc 127.0.0.1:5900 &
wayvnc_pid=$!
wait "$sway_pid"
