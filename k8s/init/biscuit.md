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

## mount

```bash
sudo mkdir -p /mnt/HDD-1TB
sudo vim /etc/fstab
```

```bash
sudo mount -a
```

```bash
sudo mkdir -p /mnt/HDD-1TB/minio
sudo chown -R 1000:1000 /mnt/HDD-1TB/minio && sudo chmod u+rxw /mnt/HDD-1TB/minio
```

## k3s

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC='--flannel-backend=none --disable-network-policy --disable=servicelb,traefik' sh -
```

## kubeconfig

```bash
sudo rm -r .kube
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Cilium

```bash
cd ~/ghq/github.com/walnuts1018/infra/k8s/apps/cilium
```

```bash
jsonnet helm.jsonnet --tla-str k8sServiceHost="192.168.0.15" --tla-code k8sServicePort=6443 --tla-str loadBalancerIP="192.168.0.159" --tla-code enableServiceMonitor=false --tla-code operatorReplicas=1 --tla-code usek3s=true | jq .spec.source.helm.valuesObject > values.json
```

```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.16.6 --namespace cilium-system --create-namespace --values values.json
```

## 1Password

```shell
eval $(op signin)
```

```shell
mkdir -p /tmp/onepassword
cd /tmp/onepassword
op connect server create biscuit --vaults kurumi
OP_TOKEN=$(op connect token create biscuit --server biscuit --vault kurumi)
```

```shell
helm repo add 1password https://1password.github.io/connect-helm-charts/
helm install onepassword-connect -n onepassword --create-namespace  1password/connect --set-file connect.credentials=1password-credentials.json --set operator.create=true --set operator.token.value=$OP_TOKEN
```

## ArgoCD

```bash
cd ~/ghq/github.com/walnuts1018/infra/k8s/_argocd/argocd_components
```

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd -n argocd --create-namespace argo/argo-cd --values ./values.yaml
```

```bash
argocd admin initial-password -n argocd
argocd login --insecure --port-forward --port-forward-namespace argocd --plaintext --username admin localhost:8080
```

```bash
argocd account update-password --insecure --port-forward --port-forward-namespace argocd --plaintext
```

```bash
cd ../clusters/biscuit
kubectl apply -f base.yaml
```

## OIDC login by kurumi

```bash
vim /etc/rancher/k3s/config.yaml
```

```diff
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
User=root
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s \
    server \
        '--flannel-backend=none' \
        '--disable-network-policy' \
        '--disable=servicelb,traefik' \
+       '--kube-apiserver-arg oidc-issuer-url=https://192.168.0.17:16443' \
+       '--kube-apiserver-arg oidc-client-id=kurumi.k8s.walnuts.dev' \
+       '--kube-apiserver-arg oidc-username-claim=sub'
```
