# 初回セットアップ

## ArgoCD インストール

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd -n argocd --create-namespace argo/argo-cd --values ./values.yaml
```

## ArgoCD CLI インストール

```bash
brew install argocd
```

## ログイン

```bash
argocd admin initial-password -n argocd
argocd login --insecure --port-forward --port-forward-namespace argocd --plaintext --username admin localhost:8080
```

```bash
op item get kma3l3fsrsfccw4c62h2f5rqfe --reveal --fields label=admin
argocd account update-password --insecure --port-forward --port-forward-namespace argocd --plaintext
```

## クラスタ追加

```bash
argocd cluster add kurumi --insecure --port-forward --port-forward-namespace argocd -y
```

## Init

```bash
kubectl apply -f k8s/_argocd/kurumi/base.yaml
```
