# Init

## 構成

- kurumi-01 RaspberryPi 4 4Core 2GB+2GB aarch64 Debian11  Control
- kurumi-02 RaspberryPi 4 4Core 4GB+2GB aarch64 Debian11  Control
- kurumi-03 QEMU          4Core 4GB+4GB amd64   Ubuntu22
- kurumi-04 Azure b1ms    1Core 2GB+1GB amd64   Ubuntu22
- kurumi-05 Azure b1s     1Core 1GB+1GB amd64   Ubuntu22  Control

## 初期設定

- kurumi-01,02
  - Raspberry Pi OS Lite 64bit Bullseye インストール
  - ```$ sudo apt update && sudo apt upgrade -y```
- kurumi-03,04,05
  - Ubuntu22 Install
- [zsh&dotfile](https://github.com/walnuts1018/dotfiles)

## Timezone

### rasp

```bash
sudo raspi-config nonint do_change_timezone Asia/Tokyo
```

### Ubuntu

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

## IP固定

### rasp

```bash
echo "
eth0
static ip_address=192.168.xxx.yyy/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1" >> /etc/dhcpcd.conf
```

再起動

## cgroups

```bash
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/cmdline.txt
```
再起動

## swap

### rasp

```bash
sudo vim /etc/dphys-swapfile
```

```bash
sudo systemctl restart dphys-swapfile
```

### Ubuntu(Azure)
```bash
sudo fallocate -l 1G /mnt/swap.img
sudo chmod 600 /mnt/swap.img
sudo mkswap /mnt/swap.img
sudo vim /etc/fstab
```

```diff
+ /mnt/swap.img none swap sw 0 0
```

```bash
sudo reboot
```

## iptables
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo apt-get install -y iptables arptables ebtables
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

sudo sysctl --system
```

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

### rasp

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Raspbian_10/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.27.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27/Raspbian_11/ /
EOF
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.27/Raspbian_11/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Raspbian_10/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
```

### ubuntu

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.27.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27/xUbuntu_22.04/ /
EOF
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.27/xUbuntu_22.04/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
```

```bash
sudo apt update
sudo apt install -y cri-o cri-o-runc
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio
```

## k8s本体
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt update
sudo apt install -y kubelet=1.27.2-00 kubeadm=1.27.2-00 kubectl=1.27.2-00
sudo apt-mark hold kubelet kubeadm kubectl
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--container-runtime-endpoint='unix:///var/run/crio/crio.sock'
EOF
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
```

## keepalived & nginx

1,2,3

```bash
sudo apt install keepalived nginx -y
keepalived --version
```

1
```bash
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections  1024;
}

stream {
  upstream kube_apiserver {
    least_conn;
    server 192.168.0.16:6443;
    }

  server {
    listen        6443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
    sendfile on;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
```

2
```bash
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections  1024;
}

stream {
  upstream kube_apiserver {
    least_conn;
    server 100.84.126.71:6443;
    }

  server {
    listen        6443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
    sendfile on;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
```

3
```bash
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections  1024;
}

stream {
  upstream kube_apiserver {
    least_conn;
    server 100.123.73.55:6443;
    }

  server {
    listen        6443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
    sendfile on;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
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

timeout 5 curl http://localhost:6443
status=$?

if [ $status -eq 0 ]; then
  logger "nginx processes are alive."
  exit 0
elif [ $status -eq 130 ]; then
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

1

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
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 120
    advert_int 1
    virtual_ipaddress {
        192.168.0.17
    }
    track_script {
      chk_nginx
      chk_nginx_processes
      maintenance_mode
    }
}
EOF
```

2

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
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 110
    advert_int 1
    virtual_ipaddress {
        192.168.0.17
    }
    track_script {
      chk_nginx
      chk_nginx_processes
      maintenance_mode
    }
}
EOF
```

3

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
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    virtual_ipaddress {
        192.168.0.17
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
sudo systemctl enable keepalived
sudo systemctl start keepalived

sudo systemctl enable nginx
sudo systemctl start nginx
```

## kubeadm

```bash
rm kubeadm-config.yaml
echo "apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: kurumi
networking:
  podSubnet: 10.244.0.0/16
controlPlaneEndpoint: 192.168.0.17:6443
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
failSwapOn: false
featureGates:
  NodeSwap: true
memorySwap:
  swapBehavior: UnlimitedSwap" > kubeadm-config.yaml

sudo kubeadm init --config kubeadm-config.yaml
```

再試行してるうちに↓
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

## taint
```bash
HOSTNAME=kurumi-01
kubectl taint node $HOSTNAME node-role.kubernetes.io/control-plane:NoSchedule-
```

## helm
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm=3.11.1-1
sudo apt-mark hold helm
```

## zsh-completion
```bash
echo "[[ /usr/bin/kubectl ]] && source <(kubectl completion zsh)
[[ /usr/bin/helm ]] && source <(helm completion zsh)" >> .zshrc
```

## Flannel
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

## longhorn
```bash
sudo apt -y install open-iscsi
```

環境チェック
```bash
sudo apt install -y jq
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/scripts/environment_check.sh | bash
```

<!-- 
### argocd 
```bash
git clone git@github.com:walnuts1018/infra.git
cd infra/k8s/init/
kubectl apply -f ./argocd/namespace.yaml
kubectl apply -n argocd -f ./argocd/install.yaml

kubectl apply -f ./applications-deployer.yaml
```
#### argocd cli
```bash
cd /tmp
curl -sSL -o argocd-linux-arm64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64
sudo install -m 555 argocd-linux-arm64 /usr/local/bin/argocd
\rm argocd-linux-arm64
cd
```
--->

## fluxcd

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
echo "[[ /usr/bin/flux ]] && source <(flux completion zsh)" >> ~/.zshrc
```

## SealedSecret

```bash
cd /tmp
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.22.0/kubeseal-0.22.0-linux-arm64.tar.gz
tar -xvzf kubeseal-0.22.0-linux-arm64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
cd 
```

(移行時)
元の方
```bash
kubectl get secret -n kube-system sealed-secrets-key8jfgr -o yaml > sealed-secrets-key.yaml

scp k1:~/sealed-secrets-key.yaml ./
```
新環境
```bash
kubeseal --fetch-cert > ~/SealedSecret.crt
```

```bash
mv sealedsecret.yaml sealedsecret2.yaml
kubeseal \
--controller-namespace=kube-system \
--controller-name=sealed-secrets-controller \
< sealedsecret2.yaml \
--recovery-unseal \
--recovery-private-key ~/sealed-secrets-key.yaml -o yaml > secret.yaml
cat secret.yaml | kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --cert ~/SealedSecret.crt -w sealedsecret.yaml
\rm sealedsecret2.yaml secret.yaml
git add .
git commit -m "[change] sealedsecret"
git push
```

## SMB CSI Driver

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/rbac-csi-smb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-driver.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-node.yaml
```

## VPA

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

## 参考

<https://qiita.com/greenteabiscuit/items/6fce805185350eab6f7a>