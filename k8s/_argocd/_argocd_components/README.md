# 初回セットアップ

## ArgoCD インストール

```bash
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install argocd -n argocd --create-namespace argo/argo-cd --values ./values.yaml
```

## ArgoCD CLI インストール

```bash
$ brew install argocd
```

## ログイン

```bash
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```

```bash
$ argocd admin initial-password -n argocd
$ argocd login --insecure --username admin localhost:8080
```

```bash
$ op item get kma3l3fsrsfccw4c62h2f5rqfe --reveal --fields label=admin
$ argocd account update-password
```

## クラスタ追加

```bash
$ argocd cluster add kurumi -y
```

## Init

```bash
$ kubectl apply -f k8s/_argocd/kurumi/base.yaml
```
