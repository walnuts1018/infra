# Argo CD初回セットアップ

`berry`に通常のArgo CDをインストールし、PrincipalとAgentを経由して`kurumi`と`biscuit`を管理する。初回のクラスター登録とリモート側のSpoke導入は[k8s/init/argocd-agent.md](../../init/argocd-agent.md)に従う。

## Argo CD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd -n argocd --create-namespace --version 10.8.2 argo/argo-cd \
  --values ./k8s/_argocd/argocd_components/values.yaml \
  --values ./k8s/_argocd/argocd_components/values.berry.yaml
```

## 管理構成

`k8s/_argocd/entrypoint/base.yaml`を適用すると、`berry`上のArgo CD、Principal、証明書、ApplicationSetが登録される。リモート向け`Application`は`argocd-agent=true`ラベルとクラスター別`AppProject`を持ち、Principalのdestination-based mappingで対象クラスターへ転送される。
