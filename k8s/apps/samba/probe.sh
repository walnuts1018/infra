#!/bin/sh
set -eu
umask 077

monitor_username=$(cat /run/secrets/username)
monitor_password=$(cat /run/secrets/password)

case "$monitor_username" in
  ''|[!A-Za-z0-9_]*|*[!A-Za-z0-9_-]*)
    echo 'monitor username contains unsupported characters' >&2
    exit 1
    ;;
esac

carriage_return=$(printf '\r')
case "$monitor_password" in
  *'
'*|*"$carriage_return"*)
    echo 'monitor password contains unsupported line breaks' >&2
    exit 1
    ;;
esac

monitor_username=$(printf '%s' "$monitor_username" | tr '[:upper:]' '[:lower:]')
mkdir -p /run/probe-auth /tmp/www
auth_file=/run/probe-auth/credentials
printf 'username = %s\npassword = %s\n' "$monitor_username" "$monitor_password" > "$auth_file"
chmod 600 "$auth_file"
unset monitor_password monitor_username

write_metrics() {
  success=$1
  last_run=$2
  tmp_file=/tmp/www/metrics.tmp
  cat > "$tmp_file" <<EOF
# HELP samba_smb_probe_success Whether the last authenticated read-only SMB share listing succeeded.
# TYPE samba_smb_probe_success gauge
samba_smb_probe_success ${success}
# HELP samba_smb_probe_last_run_timestamp_seconds Unix timestamp of the last SMB probe.
# TYPE samba_smb_probe_last_run_timestamp_seconds gauge
samba_smb_probe_last_run_timestamp_seconds ${last_run}
EOF
  mv "$tmp_file" /tmp/www/metrics
}

probe_loop() {
  while :; do
    last_run=$(date +%s)
    if timeout 15 smbclient -A "$auth_file" //samba.samba.svc.cluster.local/monitor -p 445 -t 10 -c 'ls' >/dev/null 2>&1; then
      success=1
    else
      success=0
    fi
    write_metrics "$success" "$last_run"
    sleep 30
  done
}

write_metrics 0 0
probe_loop &
probe_pid=$!

cleanup() {
  trap - EXIT HUP INT TERM
  kill "$probe_pid" 2>/dev/null || true
  wait "$probe_pid" 2>/dev/null || true
  rm -f "$auth_file" /tmp/www/metrics.tmp /tmp/www/response
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM

while :; do
  cp /tmp/www/metrics /tmp/www/response
  content_length=$(wc -c < /tmp/www/response | tr -d '[:space:]')
  {
    printf 'HTTP/1.0 200 OK\r\nContent-Type: text/plain; version=0.0.4; charset=utf-8\r\nContent-Length: %s\r\nConnection: close\r\n\r\n' "$content_length"
    cat /tmp/www/response
  } | nc -l -p 9187 -w 5 >/dev/null || true
  rm -f /tmp/www/response
done
