## 構成
 kurumi-01 (Controll) RaspberryPi 4 4GB aarch64 
 
 kurumi-02 RaspberryPi 4 2GB aarch64
 
 (kurumi-03 QEMU 2Core 2GB amd64)

## セットアップ
- kurumi-01,02 
    - Raspberry Pi OS Lite 64bit Bullseye インストール
    - ```$ sudo apt update && sudo apt upgrade -y```
    - [zshセットアップ](https://github.com/walnuts1018/zsh_on_Debian)
### ssh
任意のマシン上で
```
scp ./.ssh/id_ed25519 juglans@192.168.0.16
```

```bash
git clone git@github.com:walnuts1018/.ssh.git ssh
```

## k8sインストール
from: https://qiita.com/greenteabiscuit/items/6fce805185350eab6f7a
### Host等
```bash
sudo raspi-config nonint do_hostname kurumi-01
sudo raspi-config nonint do_change_timezone Asia/Tokyo
```

### IP固定
```bash
echo "
eth0
static ip_address=192.168.0.16/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 8.8.8.8" >> /etc/dhcpcd.conf
```

再起動

### cgroups
```bash
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/cmdline.txt
```
再起動

### swap off
```bash
sudo swapoff --all
sudo systemctl stop dphys-swapfile
sudo systemctl disable dphys-swapfile
systemctl status dphys-swapfile
```

### iptables
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

### crio
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
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
```
#### install
```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Raspbian_10/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.25.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.25/Raspbian_11/ /
EOF
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.25/Raspbian_11/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Raspbian_10/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
sudo apt update
sudo apt install -y cri-o cri-o-runc
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio
```

### k8s本体
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt update
sudo apt install -y kubelet=1.25.5-00 kubeadm=1.25.5-00 kubectl=1.25.5-00
sudo apt-mark hold kubelet kubeadm kubectl
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--container-runtime-endpoint='unix:///var/run/crio/crio.sock'
EOF
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### kubeadm
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### kubeconfig
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### taint
```bash
HOSTNAME=kurumi-01
kubectl taint node $HOSTNAME node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node $HOSTNAME node-role.kubernetes.io/master:NoSchedule-
```

## helm
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm=3.10.3-1
```

### zsh-completion
```bash
echo "[[ /usr/bin/kubectl ]] && source <(kubectl completion zsh)
[[ /usr/bin/helm ]] && source <(helm completion zsh)" >> .zshrc
```
### k8s rename
```bash
kubectl config rename-context kubernetes-admin@kubernetes 
```
### longhorn
```bash
sudo apt -y install open-iscsi
```

### argocd 
```bash
git clone git@github.com:walnuts1018/infra.git
cd infra/k8s/init/
kubectl apply -f ./argocd/namespace.yaml
kubectl apply -n argocd -f ./argocd/install.yaml

kubectl apply -f ./applications-deployer.yaml
```

### SealedSecret
```bash
cd /tmp
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.3/kubeseal-0.19.3-linux-arm.tar.gz
tar -xvzf kubeseal-0.19.3-linux-arm.tar.gz kubeseal
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