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
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -
```

## kubeconfig

```bash
sudo rm -r .kube
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
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
cd ~/ghq/github.com/walnuts1018/infra/k8s/_argocd/clusters
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
