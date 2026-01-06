```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-wireguard.conf
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.all.accept_ra=2
net.ipv6.conf.default.accept_ra=2
EOF
sudo sysctl --system
```

```bash
sudo apt-get install wireguard -y
sudo su
```

```bash
mkdir /etc/wireguard/keys
cd /etc/wireguard/keys

umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

```bash
sudo vim /etc/wireguard/wg0.conf
```

## orange

```/etc/wireguard/wg0.conf
[Interface]
Address = 192.168.1.11/32
ListenPort = 51820
PrivateKey = <key>

# cake
[Peer]
PublicKey = <cake-pubkey>
AllowedIPs = 192.168.1.21/32, 192.168.0.25/32

# cheese
[Peer]
PublicKey =  <cheese-pubkey>
AllowedIPs = 192.168.1.22/32, 192.168.0.14/32

# hotate
[Peer]
PublicKey = <hotate-pubkey>
AllowedIPs = 192.168.1.23/32, 192.168.0.26/32

# lemon
[Peer]
PublicKey = <lemon-pubkey>
AllowedIPs = 192.168.1.24/32, 192.168.0.19/32
```

## cake〜lemon

```/etc/wireguard/wg0.conf
[Interface]
Address = 192.168.1.2x/32
PrivateKey = <key>

[Peer]
PublicKey = <orange-pubkey>
Endpoint = <orange-public-ip>:51820
PersistentKeepalive = 25
AllowedIPs = 192.168.1.11/32, 172.16.0.196/32
```

```bash
sudo systemctl enable --now wg-quick@wg0
```
