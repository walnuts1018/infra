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
export ARGOCD_VERSION=v3.3.0
```

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/core-install.yaml
```
