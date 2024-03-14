# Init

## 初期設定

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

## IP 固定

### rasp

```bash
echo "
eth0
static ip_address=192.168.xxx.yyy/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1" >> /etc/dhcpcd.conf
```

再起動

### Ubuntu

インストールの時にやる

## cgroups

###rasp

```bash
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/cmdline.txt
```

再起動

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
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.29/deb /" | tee /etc/apt/sources.list.d/cri-o.list
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
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

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

## keepalived & nginx

```bash
sudo apt install keepalived nginx -y
keepalived --version
```

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
    server 192.168.0.16:6443; # to be changed
    }

  server {
    listen        16443;
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

timeout 5 curl http://localhost:16443 # to be changed
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

## kubeadm

```bash
rm kubeadm-config.yaml
echo "apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: kurumi
networking:
  podSubnet: 10.244.0.0/16
controlPlaneEndpoint: 192.168.0.17:16443
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
failSwapOn: false
featureGates:
  NodeSwap: true
  AppArmor: false
memorySwap:
  swapBehavior: UnlimitedSwap" > kubeadm-config.yaml

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

## taint

```bash
kubectl taint node $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-
```

## join

`$sudo kubeadm init phase upload-certs --upload-certs`
`$sudo kubeadm token create --print-join-command`

```bash
sudo kubeadm join 192.168.0.17:16443 --token xxx \
        --discovery-token-ca-cert-hash sha256:xxx \
        --control-plane --certificate-key xxxx
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

## longhorn

```bash
sudo apt -y install open-iscsi nfs-common
sudo systemctl start iscsid
sudo systemctl enable iscsid
```

## fluxcd

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
echo "[[ /usr/bin/flux ]] && source <(flux completion zsh)" >> ~/.zshrc
```

```bash
flux bootstrap github --owner=walnuts1018 --repository=infra --branch=deploy --path=./k8s/_flux/kurumi/ --components-extra=image-reflector-controller,image-automation-controller --reconcile --token-auth --personal
```

<!--
## SMB CSI Driver

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/rbac-csi-smb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-driver.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/v1.9.0/csi-smb-node.yaml
```
--->

## VPA

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```
