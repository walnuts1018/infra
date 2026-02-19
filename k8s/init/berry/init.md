# berry init

## Raspberry Pi OS Lite (64bit)

use Raspberry Pi Imager

## Setup

### /boot/firmware

```bash
sudo su
```

```bash
sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/firmware/cmdline.txt
rpi-eeprom-update -a
echo -n "dtoverlay=cma,cma-64
dtoverlay=disable-bt
dtoverlay=disable-wifi
dtparam=watchdog=on
" >> /boot/firmware/config.txt

exit
```

再起動

### Timezone

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

### IP 固定

いい感じにやる

## k3s Install

`/etc/rancher/k3s/config.yaml` を作成

```bash
sudo mkdir -p /etc/rancher/k3s
sudo vim /etc/rancher/k3s/config.yaml
```

```yaml
write-kubeconfig-mode: "0644"
disable:
- traefik
- servicelb
- local-storage
```

```bash
curl -sfL https://get.k3s.io | sh -
```

### kubeconfig

```bash
sudo rm -r .kube
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Secret for 1Password Connect

```bash
kubectl create namespace onepassword
kubectl create secret generic op-credentials -n onepassword --from-literal=1password-credentials.json="$(op read "op://kurumi/k8s Credentials File/1password-credentials.json")"
kubectl create secret generic onepassword-token -n onepassword --from-literal=token="$(op read "op://kurumi/pcookjymtl2zwyozhofaco5yhy/credential")"
```

## ArgoCD

### ArgoCD インストール

```bash
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm template -n argocd argocd argo/argo-cd | kubectl apply --server-side --force-conflicts -f -
```

### ArgoCD CLI インストール

```bash
brew install argocd
```

### パスワード

```bash
argocd account update-password --insecure --port-forward --port-forward-namespace argocd --plaintext --current-password $(argocd admin initial-password -n argocd
) --new-password $(op item get kma3l3fsrsfccw4c62h2f5rqfe --reveal --fields label=admin)
```

### ログイン

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

<http://localhost:8080>

### Init

```bash
kubectl apply -f k8s/_argocd/clusters/berry/base.yaml
```
