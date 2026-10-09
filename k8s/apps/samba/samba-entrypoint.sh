#!/bin/sh
set -eu

monitor_username=$(cat /run/secrets/username)
monitor_password=$(cat /run/secrets/password)

case "$monitor_username" in
  ''|[!A-Za-z0-9_]*|*[!A-Za-z0-9_-]*)
    echo 'monitor username contains unsupported characters' >&2
    exit 1
    ;;
esac

monitor_username=$(printf '%s' "$monitor_username" | tr '[:upper:]' '[:lower:]')
carriage_return=$(printf '\r')
case "$monitor_password" in
  *'
'*|*"$carriage_return"*)
    echo 'monitor password contains unsupported line breaks' >&2
    exit 1
    ;;
esac

monitor_share="[monitor]; path=/samba-share; valid users = ${monitor_username}; read only = yes; writable = no; browseable = no; available = yes"
unset carriage_return

exec env \
  "ACCOUNT_${monitor_username}=${monitor_password}" \
  "GROUPS_${monitor_username}=samba" \
  "SAMBA_VOLUME_CONFIG_monitor=${monitor_share}" \
  /container/scripts/entrypoint.sh "$@"
