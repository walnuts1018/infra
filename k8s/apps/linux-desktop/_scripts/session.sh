#!/usr/bin/env bash
set -Eeuo pipefail

export HOME=/home/walnuts
export USER=walnuts
export LOGNAME=walnuts
export XDG_RUNTIME_DIR=/run/user/1000
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS='@im=fcitx'
install -d -o 1000 -g 1000 -m 0700 "$XDG_RUNTIME_DIR"

exec /usr/bin/setpriv \
  --reuid=1000 \
  --regid=1000 \
  --init-groups \
  /usr/bin/dbus-run-session -- \
  /usr/bin/bash /run/linux-desktop-launcher/sway-session.sh
