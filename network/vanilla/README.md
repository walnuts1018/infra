# Vanilla

```sh
mise run network:render
```

```sh
scp network/.generated/vanilla/config.boot vyos@vyos.example.net:next.config
scp network/.generated/vanilla/v6plus-fcs.env vyos@vyos.example.net:v6plus-fcs.env
scp network/vanilla/config/scripts/v6plus-prefix-watch.sh vyos@vyos.example.net:v6plus-prefix-watch.sh
```

```sh
sudo install -d -m 700 /config/auth
sudo install -d -m 755 /config/scripts
sudo install -m 600 /home/vyos/v6plus-fcs.env /config/auth/v6plus-fcs.env
sudo install -m 700 /home/vyos/v6plus-prefix-watch.sh /config/scripts/v6plus-prefix-watch.sh
sudo install -m 600 /home/vyos/next.config /config/next.config
rm -f /home/vyos/v6plus-fcs.env /home/vyos/v6plus-prefix-watch.sh /home/vyos/next.config
```

```text
configure
load /config/next.config
compare
commit-confirm 10
```

```text
confirm
save
exit
```

```sh
sudo /config/scripts/v6plus-prefix-watch.sh
```
