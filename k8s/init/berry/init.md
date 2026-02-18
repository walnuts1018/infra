# berry init

## Download Talos Linux Image

<https://factory.talos.dev/?arch=arm64&board=rpi_generic&bootloader=auto&cmdline-set=true&extensions=-&platform=metal&target=sbc&version=1.12.4>

## Install Talos Linux

use Raspberry Pi Imager

## Setup Node

```bash
cd talos
```

```bash
make gen-init-config
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

## Secret for 1Password Connect

```bash
kubectl create namespace onepassword
kubectl create secret generic op-credentials -n onepassword --from-literal=1password-credentials.json="$(op read "op://kurumi/k8s Credentials File/1password-credentials.json")"
kubectl create secret generic onepassword-token -n onepassword --from-literal=token="$(op read "op://kurumi/pcookjymtl2zwyozhofaco5yhy/credential")"
```

## Cilium

```bash
kubectl create namespace cilium-system
kubectl label namespace cilium-system pod-security.kubernetes.io/enforce=privileged
helm repo add cilium https://helm.cilium.io/
helm template -n cilium-system cilium/cilium --version 1.18.6 --set ipam.mode=kubernetes --set kubeProxyReplacement=true --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" --set cgroup.autoMount.enabled=false --set cgroup.hostRoot=/sys/fs/cgroup --set k8sServiceHost=localhost --set k8sServicePort=7445 | kubectl apply --server-side --force-conflicts -f -
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
