# Init

## 前提

- OS: Ubuntu24.04

## 初期設定

- [zsh&dotfile](https://github.com/walnuts1018/dotfiles)

## Timezone

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

## IP 固定

インストールの時にやる

## crio

```bash
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward = 1
net.ipv4.ip_nonlocal_bind = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
```

```bash
sudo apt update
sudo apt install -y software-properties-common curl
```

````bash
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/deb /" | sudo tee /etc/apt/sources.list.d/cri-o.list
```

```bash
sudo apt update
sudo apt install -y cri-o
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio
````

## k8s 本体

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--container-runtime-endpoint='unix:///var/run/crio/crio.sock'
EOF
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
```

## nginx & keepalived

```bash
sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx
sudo apt update
sudo apt install keepalived nginx -y
```

```bash
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

stream {
  upstream kube_apiserver {
    least_conn;
    server $(hostname -I | cut -f1 -d' '):6443; # to be changed
    }

  server {
    listen        16443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF
```

```bash
cat <<EOF | sudo tee /etc/keepalived/chk_nginx_status.sh
#!/usr/bin/bash
systemctl is-active nginx
EOF

cat <<EOF | sudo tee /etc/keepalived/chk_nginx_proc.sh
#!/usr/bin/bash

timeout 5 curl -k https://localhost:16443
status=\$?

if [ \$status -eq 0 ]; then
  logger "nginx processes are alive."
  exit 0
elif [ \$status -eq 130 ]; then
  logger "nginx process is hanging up."
  exit 1
else
  logger "Something is wrong."
  exit 1
fi
EOF

cat <<EOF | sudo tee /etc/keepalived/maintenance.sh
#!/bin/sh

[ -f "/etc/keepalived/maintenance" ] && exit 1

exit 0
EOF
```

```bash
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
}

vrrp_script chk_nginx {
    script "/etc/keepalived/chk_nginx_status.sh"
    interval 2
    fall 2
    rise 2
}

vrrp_script chk_nginx_processes {
    script "/etc/keepalived/chk_nginx_proc.sh"
    interval 2
    fall 2
    rise 2
}

vrrp_script maintenance_mode {
    script "/etc/keepalived/maintenance.sh"
    interval 2
    weight 50
}

vrrp_instance VI_1 {
    state MASTER / BACKUP # to be changed
    interface eth0 # to be changed
    virtual_router_id 51
    priority 120 # to be changed
    advert_int 1
    virtual_ipaddress {
        192.168.0.17 # to be changed
    }
    track_script {
      chk_nginx
      chk_nginx_processes
      maintenance_mode
    }
}
EOF
```

```bash
sudo useradd keepalived_script
sudo chmod +x /etc/keepalived/*.sh

sudo systemctl enable keepalived
sudo systemctl start keepalived

sudo systemctl enable nginx
sudo systemctl start nginx
```

## longhorn

```bash
sudo apt -y install open-iscsi nfs-common
sudo systemctl start iscsid
sudo systemctl enable iscsid
```

## kubeadm

```bash
rm kubeadm-config.yaml
echo "apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
clusterName: kurumi
controlPlaneEndpoint: 192.168.0.17:16443
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///var/run/crio/crio.sock
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
failSwapOn: false
featureGates:
  NodeSwap: true
memorySwap:
  swapBehavior: LimitedSwap" > kubeadm-config.yaml

sudo kubeadm init --config kubeadm-config.yaml
```

再試行してるうちに ↓

## swap support

```bash
sudo vim /var/lib/kubelet/kubeadm-flags.env
```

`--feature-gates=NodeSwap=true` を追加

## kubeconfig

```bash
sudo rm -r .kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## kubeproxy

```bash
kubectl -n kube-system delete ds kube-proxy
kubectl -n kube-system delete cm kube-proxy
```

## taint

```bash
kubectl taint node $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-
```

## join

### Control Plane

```bash
echo "sudo" $(sudo kubeadm token create --print-join-command) "--control-plane --certificate-key" $(sudo kubeadm init phase upload-certs --upload-certs | tail -n 1) "--cri-socket unix:///var/run/crio/crio.sock"
```

👆 を実行

### Worker

```bash
echo "sudo" $(sudo kubeadm token create --print-join-command) "--cri-socket unix:///var/run/crio/crio.sock"
```

👆 を実行

## helm

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## fluxcd

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
# echo "[[ /usr/bin/flux ]] && source <(flux completion zsh)" >> ~/.zshrc
```

```bash
flux bootstrap github --owner=walnuts1018 --repository=infra --branch=deploy --path=./k8s/_flux/kurumi/ --components-extra=image-reflector-controller,image-automation-controller --reconcile --ssh-key-algorithm=ed25519 --read-write-key=true
```

## labels

```bash
kubectl label nodes peach walnuts.dev/ondemand=true
```

## 1Password

```bash
helm install onepassword-connect -n onepassword --create-namespace  1password/connect --set connect.credentials='(op read "op://kurumi k8s cluster/kurumi Credentials File/1password-credentials.json")' --set operator.create=true --set operator.token.value='(op read "op://kurumi k8s cluster/mhc7wnb4oe3kevaiubx3cxz7du/credential")'
```
