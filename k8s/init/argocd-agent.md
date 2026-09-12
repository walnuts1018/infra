# Argo CD Agent初期化

## 構成

`berry`は通常のArgo CDとPrincipalを実行する。`kurumi`と`biscuit`はローカルのArgo CD application-controller、repo-server、Redis、Agentを実行し、アプリケーションの同期はAgent経由で行う。`biscuit`はCAPIのClusterResourceSetとHelmChartProxyで自動Bootstrapするため、この文書の手動Spoke導入手順は`kurumi`だけを対象とする。

Agentの接続先は`argocd-agent.local.walnuts.dev:443`とする。この名前がPrincipal ServiceのLoadBalancerアドレスを解決すること、リモートクラスターから`443/tcp`へ接続できることを先に確認する。

## ハブ側の準備

以下は`berry`のcontextを使用して実行する。RedisとRedisの認証SecretはArgo CD Helmチャートが生成する。JWT鍵と証明書の秘密鍵はコマンドと`cert-manager`がクラスター内で生成し、Gitには保存しない。

```bash
argocd-agentctl --principal-context berry --principal-namespace argocd jwt create-key
```

`argocd-agent-certs`を同期し、CA、各クラスターのクライアント証明書、Self-registration用共有クライアント証明書が作成されたことを確認する。Self-registrationは`v0.10.0`のBeta機能であり、認証済みAgentのクラスターSecretをPrincipalが生成するために使用する。

```bash
argocd app sync argocd-agent-certs --project berry
kubectl --context berry -n argocd get secret argocd-agent-ca
kubectl --context berry -n argocd get secret argocd-agent-client-tls-kurumi
kubectl --context berry -n argocd get secret argocd-agent-client-tls-biscuit
kubectl --context berry -n argocd get secret argocd-agent-shared-client-cert
```

## リモート側のSpoke導入

この手順は`kurumi`だけで実行する。リモート側へ渡す証明書は一時ファイルを作らず、Secretから直接`kubectl`へ渡す。既存クラスターの移行完了後はberry上のGitOps管理下にある`argocd-spoke-kurumi`と`argocd-agent-kurumi`で変更する。

```bash
CLUSTER_CONTEXT=kurumi

kubectl --context "$CLUSTER_CONTEXT" create namespace argocd --dry-run=client -o yaml \
  | kubectl --context "$CLUSTER_CONTEXT" apply -f -

kubectl --context "$CLUSTER_CONTEXT" -n argocd create secret tls argocd-agent-client-tls \
  --cert=<(kubectl --context berry -n argocd get secret "argocd-agent-client-tls-$CLUSTER_CONTEXT" -o jsonpath='{.data.tls\.crt}' | base64 --decode) \
  --key=<(kubectl --context berry -n argocd get secret "argocd-agent-client-tls-$CLUSTER_CONTEXT" -o jsonpath='{.data.tls\.key}' | base64 --decode) \
  --dry-run=client -o yaml | kubectl --context "$CLUSTER_CONTEXT" apply -f -

kubectl --context "$CLUSTER_CONTEXT" -n argocd create secret generic argocd-agent-ca \
  --from-file=ca.crt=<(kubectl --context berry -n argocd get secret argocd-agent-ca -o jsonpath='{.data.tls\.crt}' | base64 --decode) \
  --dry-run=client -o yaml | kubectl --context "$CLUSTER_CONTEXT" apply -f -

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 10.8.2 --kube-context "$CLUSTER_CONTEXT" \
  --namespace argocd --create-namespace --values k8s/_argocd/spoke/values.yaml
AGENT_SOURCE_DIR="$(mktemp -d)"
git clone --depth 1 --branch v0.10.0 https://github.com/argoproj-labs/argocd-agent "$AGENT_SOURCE_DIR/argocd-agent"
helm upgrade --install argocd-agent "$AGENT_SOURCE_DIR/argocd-agent/install/helm-repo/argocd-agent-agent" \
  --kube-context "$CLUSTER_CONTEXT" --namespace argocd --create-namespace \
  --values k8s/_argocd/agent/agent/values.yaml
rm -rf "$AGENT_SOURCE_DIR"
```

Agentの接続先を変更する場合は、`k8s/_argocd/agent/agent/values.yaml`の`server`と、Principal証明書のSANを同じ名前に変更する。`biscuit`の接続先やTLS Secretは`k8s/clusters/biscuit/argocd-agent-clusterresourceset.jsonnet`と`k8s/clusters/biscuit/argocd-agent-resources-externalsecret.jsonnet`が生成する。

`infra-private`のRepository Secretは認証情報を含むため、このリポジトリでは管理しない。berryのArgo CDで該当Secretに`argocd-agent=true`ラベルを付け、Agent側へ配送されることを確認する。

```bash
kubectl --context berry -n argocd label secret <infra-private-repository-secret> argocd-agent=true --overwrite
kubectl --context biscuit -n argocd get secret -l argocd-agent=true
```

この時点ではHelmリリースを削除せず、berry上のApplicationが既存リソースを引き継ぐまで`helm upgrade`も実行しない。`kurumi`の継続管理用Applicationが正本であり、Spoke上へ直接Applicationを作成する必要はない。

## Principalへの自動登録

リモート側Agentが起動すると、PrincipalがAgentの認証後に`skip-reconcile`付きのクラスターSecretを自動生成する。AgentごとのクラスターSecretをGitへ保存したり、`argocd-agentctl agent create`を実行したりしない。

```bash
kubectl --context berry -n argocd get secret \
  -l argocd-agent.argoproj-labs.io/self-registered-cluster=true
```

`cluster-kurumi`と`cluster-biscuit`が生成され、`argocd-agent.argoproj-labs.io/agent-name`ラベルと`argocd.argoproj.io/skip-reconcile: "true"`アノテーションが付いていることを確認する。これらのSecretはPrincipalが管理するため、手動編集やGitへの取り込みを行わない。

Agent接続後、berryの`base` Applicationを同期して、SpokeとAgentのApplicationをGitから作成または更新する。

```bash
argocd app sync base --project berry
argocd app get argocd-spoke-kurumi --refresh
argocd app get argocd-agent-kurumi --refresh
```

以後はGitの変更をberryの`base` Applicationへ同期する。対象クラスターへ直接Helmを実行したり、Spoke上でApplicationを手動作成したりしない。クラスター廃止時は、対象ApplicationとCAPIリソースを依存関係を確認しながら手動で削除する。

## 移行順序

既存の直接管理用Argo CDがリモートクラスターで動作している場合は、先にそのApplicationの自動pruneを停止する。次にリモート側の旧Argo CDが管理していたapplication-controllerとrepo-serverをSpoke構成へ置き換え、Agent接続を確認してから旧来の`argocd cluster add`で作成したクラスターSecretとApplicationをGitから削除する。同期後にアプリケーション、PVC、ExternalSecret、Secretの状態を確認し、旧リソースの削除が発生していないことを確認する。クラスターを廃止する場合は、対象ApplicationとCAPIリソースを依存関係を確認しながら手動で削除する。

## 確認

```bash
kubectl --context berry -n argocd get deployment argocd-agent
kubectl --context berry -n argocd get secret cluster-kurumi -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/skip-reconcile}'
kubectl --context berry -n argocd get secret cluster-biscuit -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/skip-reconcile}'
kubectl --context kurumi -n argocd get pods
kubectl --context kurumi -n argocd logs deployment/argocd-agent
argocd app list
```

PrincipalのログにAgent接続、AgentのログにPrincipalへのイベントストリーム接続が出力され、Agentラベル付きApplicationが`Synced`かつ`Healthy`になることを受け入れ条件とする。
