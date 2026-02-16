# berry init

## Download Talos Linux Image

<https://factory.talos.dev/?arch=arm64&board=rpi_generic&bootloader=auto&cmdline-set=true&extensions=-&platform=metal&target=sbc&version=1.12.4>

## Install Talos Linux

use Raspberry Pi Imager

## Setup Node

```bash
mv talos
```

```bash
make initial-apply INITIAL_NODE_IP=192.168.0.107
```

```bash
make bootstrap
```

```bash
make get-kubeconfig
```

```bash
vim ~/.kube/config
```

## ArgoCD

### ArgoCD インストール

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### ArgoCD CLI インストール

```bash
brew install argocd
```

### ログイン

```bash
argocd admin initial-password -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

<http://localhost:8080>

### Init

```bash
kubectl apply -f k8s/_argocd/berry/base.yaml
```
