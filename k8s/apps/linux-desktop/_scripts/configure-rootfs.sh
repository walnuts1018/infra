#!/usr/bin/env bash
set -Eeuo pipefail

pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm
pacman -S --needed --noconfirm \
  base \
  base-devel \
  sudo git openssh \
  sway wayvnc xorg-xwayland foot fuzzel waybar mako wl-clipboard grim slurp \
  dbus polkit xdg-desktop-portal xdg-desktop-portal-wlr \
  pipewire pipewire-pulse wireplumber \
  mesa vulkan-swrast \
  firefox \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-mozc fcitx5-qt

if getent passwd 1000 >/dev/null; then
  echo 'UID 1000 is already assigned in the source root filesystem.' >&2
  exit 1
fi
if getent group 1000 >/dev/null; then
  echo 'GID 1000 is already assigned in the source root filesystem.' >&2
  exit 1
fi

groupadd --gid 1000 walnuts
useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash walnuts
install -d -m 0755 /etc/sudoers.d
printf 'walnuts ALL=(ALL:ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/walnuts
chmod 0440 /etc/sudoers.d/walnuts
visudo --check --file=/etc/sudoers.d/walnuts

if grep -q '^#ja_JP.UTF-8 UTF-8' /etc/locale.gen; then
  sed -i 's/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
elif ! grep -q '^ja_JP.UTF-8 UTF-8' /etc/locale.gen; then
  printf 'ja_JP.UTF-8 UTF-8\n' >> /etc/locale.gen
fi
locale-gen
printf 'LANG=ja_JP.UTF-8\n' > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

install -d -o 1000 -g 1000 -m 0755 /home/walnuts/.config/sway
if [[ ! -e /home/walnuts/.config/sway/config ]]; then
  cat > /home/walnuts/.config/sway/config <<'SWAY_CONFIG'
set $mod Mod4
font pango:Noto Sans CJK JP 10

output * resolution 1920x1080

input type:keyboard {
    xkb_layout jp
}

exec fcitx5 -d
exec waybar
exec mako

bindsym $mod+Return exec foot
bindsym $mod+d exec fuzzel
bindsym $mod+Shift+e exec swaymsg exit
SWAY_CONFIG
fi
chown -R 1000:1000 /home/walnuts
