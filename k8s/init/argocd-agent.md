# Argo CD Agent初期化

## 構成

`berry`は通常のArgo CDとPrincipalを実行する。`kurumi`と`biscuit`はローカルのArgo CD application-controller、repo-server、Redis、Agentを実行し、アプリケーションの同期はAgent経由で行う。

Agentの接続先は`argocd-agent.local.walnuts.dev:443`とする。この名前がPrincipal ServiceのLoadBalancerアドレスを解決すること、リモートクラスターから`443/tcp`へ接続できることを先に確認する。

## ハブ側の準備

以下は`berry`のcontextを使用して実行する。`argocd-redis`の`auth`は既存のValkeyが認証なしで動作するための空値であり、秘密情報ではない。JWT鍵と証明書の秘密鍵はコマンドと`cert-manager`がクラスター内で生成し、Gitには保存しない。

```bash
kubectl --context berry -n argocd create secret generic argocd-redis \
  --from-literal=auth= \
  --dry-run=client -o yaml | kubectl --context berry apply -f -

argocd-agentctl --principal-context berry --principal-namespace argocd jwt create-key
```

`argocd-agent-certs`を同期し、CAと各クラスターのクライアント証明書が作成されたことを確認する。

```bash
argocd app sync argocd-agent-certs --project berry
kubectl --context berry -n argocd get secret argocd-agent-ca
kubectl --context berry -n argocd get secret argocd-agent-client-tls-kurumi
kubectl --context berry -n argocd get secret argocd-agent-client-tls-biscuit
```

## リモート側のSpoke導入

各クラスターで同じ手順を実行し、`CLUSTER_CONTEXT`だけ対象に合わせる。リモート側へ渡す証明書は一時ファイルを作らず、Secretから直接`kubectl`へ渡す。

```bash
CLUSTER_CONTEXT=kurumi

kubectl --context "$CLUSTER_CONTEXT" create namespace argocd --dry-run=client -o yaml \
  | kubectl --context "$CLUSTER_CONTEXT" apply -f -

kubectl --context "$CLUSTER_CONTEXT" -n argocd create secret tls argocd-agent-client-tls \
  --cert=<(kubectl --context berry -n argocd get secret "argocd-agent-client-tls-$CLUSTER_CONTEXT" -o jsonpath='{.data.tls\.crt}' | base64 --decode) \
  --key=<(kubectl --context berry -n argocd get secret "argocd-agent-client-tls-$CLUSTER_CONTEXT" -o jsonpath='{.data.tls\.key}' | base64 --decode) \
  --dry-run=client -o yaml | kubectl --context "$CLUSTER_CONTEXT" apply -f -

kubectl --context "$CLUSTER_CONTEXT" -n argocd create secret generic argocd-agent-ca \
  --from-file=ca.crt=<(kubectl --context berry -n argocd get secret argocd-agent-ca -o jsonpath='{.data.ca\.crt}' | base64 --decode) \
  --dry-run=client -o yaml | kubectl --context "$CLUSTER_CONTEXT" apply -f -

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --kube-context "$CLUSTER_CONTEXT" \
  --namespace argocd --create-namespace --values k8s/_argocd/spoke/values.yaml
AGENT_SOURCE_DIR="$(mktemp -d)"
git clone --depth 1 --branch v0.9.0 https://github.com/argoproj-labs/argocd-agent "$AGENT_SOURCE_DIR/argocd-agent"
helm upgrade --install argocd-agent "$AGENT_SOURCE_DIR/argocd-agent/install/helm-repo/argocd-agent-agent" \
  --kube-context "$CLUSTER_CONTEXT" --namespace argocd --create-namespace \
  --values k8s/_argocd/agent/agent/values.yaml
rm -rf "$AGENT_SOURCE_DIR"
```

`biscuit`でも`CLUSTER_CONTEXT=biscuit`として実行する。Agentの接続先を変更する場合は、`k8s/_argocd/agent/agent/values.yaml`の`server`と、Principal証明書のSANを同じ名前に変更する。

## Principalへの登録

リモート側Agentが起動できる状態になった後、`berry`で各Agentを登録する。`agent create`が`skip-reconcile`付きのクラスターSecretを生成するため、SecretをGitへ作成しない。

```bash
CLUSTER_NAME=kurumi

argocd-agentctl --principal-context berry --principal-namespace argocd agent create "$CLUSTER_NAME" \
  --resource-proxy-server argocd-agent-resource-proxy:9090 \
  --tls-from-secret "argocd-agent-client-tls-$CLUSTER_NAME" \
  --ca-from-secret argocd-agent-ca
```

`biscuit`も`CLUSTER_NAME=biscuit`として実行する。生成された`cluster-kurumi`と`cluster-biscuit`には`argocd-agent.argoproj-labs.io/agent-name`ラベルと`argocd.argoproj.io/skip-reconcile: "true"`アノテーションが必要であり、これらを失った場合はAgent管理へ切り替えない。

## 移行順序

既存の直接管理用Argo CDがリモートクラスターで動作している場合は、先にそのApplicationの自動pruneを停止する。次にリモート側の旧Argo CDが管理していたapplication-controllerとrepo-serverをSpoke構成へ置き換え、Agent接続を確認してから旧来の`argocd cluster add`で作成したクラスターSecretとApplicationをGitから削除する。同期後にアプリケーション、PVC、ExternalSecret、Secretの状態を確認し、旧リソースの削除が発生していないことを確認する。

## 確認

```bash
kubectl --context berry -n argocd get deployment argocd-agent
kubectl --context berry -n argocd get secret cluster-kurumi -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/skip-reconcile}'
kubectl --context kurumi -n argocd get pods
kubectl --context kurumi -n argocd logs deployment/argocd-agent
argocd app list
```

PrincipalのログにAgent接続、AgentのログにPrincipalへのイベントストリーム接続が出力され、Agentラベル付きApplicationが`Synced`かつ`Healthy`になることを受け入れ条件とする。
