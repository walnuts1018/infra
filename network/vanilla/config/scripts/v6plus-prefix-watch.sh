#!/bin/vbash

set -u

IFACE='eth0.251'
TUNNEL='tun0'

STATE='/config/auth/v6plus-last-src'
CREDENTIALS='/config/auth/v6plus-fcs.env'

TAG='v6plus-prefix-watch'
LOCK='/run/lock/v6plus-prefix-watch.lock'

SELF="$(readlink -f "$0")" || exit 1

# VyOS の configuration session は vyattacfg group で実行する必要がある。
# sudo で config command を実行するのではなく、公式推奨どおり
# sg vyattacfg 経由で再実行する。
if [ "$(id -gn)" != 'vyattacfg' ]; then
    printf -v QUOTED_SELF '%q' "$SELF"
    exec sg vyattacfg -c "/bin/vbash $QUOTED_SELF"
fi

fail() {
    logger -t "$TAG" -- "$1"
    exit 1
}

# prefix change の検知が短時間に複数回発生しても、
# config session / FCS update を並行実行させない。
exec 9>"$LOCK" || fail "cannot open lock file: $LOCK"

if ! /usr/bin/flock -n 9; then
    logger -t "$TAG" "another instance is already running"
    exit 0
fi

# 2000::/3 の global unicast address のうち最初のものを利用する。
ADDR="$(
    /usr/sbin/ip -6 -o addr show dev "$IFACE" scope global 2>/dev/null \
        | /usr/bin/awk '
            $4 ~ /^[23]/ {
                sub(/\/.*/, "", $4)
                print $4
                exit
            }
        '
)"

[ -n "$ADDR" ] || fail "no global IPv6 address on $IFACE"

[ -r "$CREDENTIALS" ] \
    || fail "credential file not readable: $CREDENTIALS"

# shellcheck disable=SC1090
. "$CREDENTIALS"

[ -n "${FCS_USER:-}" ] || fail "FCS_USER is empty"
[ -n "${FCS_PASS:-}" ] || fail "FCS_PASS is empty"

# 前回、FCS + VyOS config の両方を正常に反映できた address。
OLD="$(cat "$STATE" 2>/dev/null || true)"

# 現在 kernel 上で tun0 が使っている source address。
CURRENT="$(
    /usr/sbin/ip -d link show dev "$TUNNEL" 2>/dev/null \
        | /usr/bin/awk '
            /link\/tunnel6/ {
                print $2
                exit
            }
        '
)"

#   - script-template はこのサブシェル内でのみ source する
#   - configure を必要な場合にしか実行しない
#   - set -e は使わない
#   - すべての失敗経路で通常の "exit" を通す
#   - builtin exit は絶対に使わない
# これにより new_config_* / changes_only_* の FUSE session が
# 親プロセス側へ漏れることを防ぐ。
apply_tunnel_config() (
    DESIRED="$1"

    source /opt/vyatta/etc/functions/script-template

    # SIGTERM 等でも、可能な限り configuration session の
    # cleanup を実行する。
    trap '
        discard >/dev/null 2>&1 || true
        exit 1
    ' HUP INT TERM

    if ! configure; then
        logger -t "$TAG" "failed to enter configuration mode"
        exit 1
    fi

    # source-address は scalar value なので、一度 delete する必要はない。
    # set だけで desired value に置き換えられる。
    if ! set interfaces tunnel "$TUNNEL" source-address "$DESIRED"; then
        logger -t "$TAG" "failed to set $TUNNEL source-address"
        discard >/dev/null 2>&1 || true
        exit 1
    fi

    if ! commit; then
        logger -t "$TAG" "commit failed"
        discard >/dev/null 2>&1 || true
        exit 1
    fi

    # STATE は save 成功後にしか更新しない。
    # save に失敗した場合、次回もう一度この処理を行うことで
    # config.boot への永続化を再試行できる。
    if ! save; then
        logger -t "$TAG" "save failed"
        exit 1
    fi

    trap - HUP INT TERM

    # script-template が提供する通常の exit。
    # FUSE configuration session の cleanup に必要。
    exit 0
)

# IPv6 address 自体が変わった場合のみ FCS を更新する。
if [ "$ADDR" != "$OLD" ]; then
    logger -t "$TAG" \
        "address changed: ${OLD:-none} -> $ADDR; updating FCS"

    if ! REPLY="$(
        /usr/bin/curl \
            -g \
            -6 \
            --interface "$ADDR" \
            --fail \
            --silent \
            --show-error \
            --connect-timeout 10 \
            --max-time 30 \
            --get \
            --data-urlencode "user=$FCS_USER" \
            --data-urlencode "pass=$FCS_PASS" \
            'http://fcs.enabler.ne.jp/update'
    )"; then
        fail "FCS update request failed"
    fi

    REPLY="$(printf '%s' "$REPLY" | /usr/bin/tr -d '\r\n')"

    [ "$REPLY" = 'OK' ] \
        || fail "FCS rejected update: $REPLY"

    logger -t "$TAG" "FCS accepted update"

    # OLD != ADDR の場合は CURRENT が既に一致していても必ず
    # config + save を行う。
    # これにより、前回 commit は成功したが save/state 更新前に
    # 異常終了したケースも自己修復できる。
    logger -t "$TAG" \
        "ensuring $TUNNEL source-address: ${CURRENT:-unknown} -> $ADDR"

    apply_tunnel_config "$ADDR" \
        || fail "failed to update $TUNNEL configuration"

elif [ "$CURRENT" != "$ADDR" ]; then
    # STATE/FCS は正常だが runtime config がずれているケース。
    # FCS を再更新せず VyOS 側だけ自己修復する。
    logger -t "$TAG" \
        "$TUNNEL source-address drift detected: ${CURRENT:-unknown} -> $ADDR"

    apply_tunnel_config "$ADDR" \
        || fail "failed to repair $TUNNEL configuration"

else
    logger -t "$TAG" "unchanged: $ADDR"
    exit 0
fi

# FCS update + commit + save がすべて完了して初めて STATE を更新する。
# 同一 filesystem 上で temporary file -> rename するため、
# truncate 途中の state file を残さない。
STATE_TMP="${STATE}.tmp.$$"

if ! (
    umask 077
    printf '%s\n' "$ADDR" > "$STATE_TMP"
); then
    rm -f -- "$STATE_TMP"
    fail "failed to write temporary state file"
fi

if ! mv -f -- "$STATE_TMP" "$STATE"; then
    rm -f -- "$STATE_TMP"
    fail "failed to update state file"
fi

logger -t "$TAG" \
    "completed: $TUNNEL source-address=$ADDR"

exit 0
