# 初回セットアップ

Argo CDはberry clusterにのみinstallし、berryと登録済みのworkload clusterを管理する。

## Argo CD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd -n argocd --create-namespace argo/argo-cd \
  --values ./k8s/_argocd/argocd_components/values.yaml \
  --values ./k8s/_argocd/argocd_components/values.berry.yaml
```

## Cluster登録

kurumiのcontext名が`kurumi`であるkubeconfigを使い、berry上のArgo CDへ登録する。

```bash
argocd cluster add kurumi --name kurumi --insecure --port-forward --port-forward-namespace argocd -y
```

biscuitもcluster構築とAPIの到達性を確認した後、同じ方法で`biscuit`として登録する。登録後に`k8s/_argocd/applications/biscuit`を追加すれば、berryのbase Applicationが自動的に読み込む。

## 管理構成

```bash
kubectl apply -f k8s/_argocd/clusters/berry/base.yaml
```

base Applicationは`k8s/_argocd/applications` 以下を再帰的に読み込む。`berry`は同一cluster、`kurumi`はArgo CDに登録したremote clusterをdestinationとする。
