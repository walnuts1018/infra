# Argo CD Agent運用ガイド

## アーキテクチャ概要

本環境では、Argo CD Agentを用いたマルチクラスタ構成を採用しています。

- 管理クラスタ(`berry`)でArgo CD Principal、ApplicationSet、cert-manager、External Secrets Operatorを実行します。
- ワークロードクラスタ(`kurumi`、`biscuit`)でArgo CD Spoke、application-controller、repo-server、Redis、Argo CD Agentを実行し、Applicationの実リソースは各ワークロードクラスタ内でReconcileされます。

ワークロードクラスタへのSpokeやAgentのデプロイは、CAPIのClusterResourceSetおよびHelmChartProxyにより自動で行われます。

Agentは`argocd-agent.local.walnuts.dev:443`経由でPrincipalに接続します。この名前のAレコードはAgentや`kurumi`/`biscuit`のApplicationに依存しない外部DNSで管理し、berryのServiceLBアドレスを参照します。通信に必要なmTLS証明書(Principal証明書、CA、各ワークロードクラスタ用のクライアント証明書)は、すべて`berry`上のcert-managerが発行・管理します。
また、Principalがクラスタ自動登録(Self-registration)時に生成するcluster Secretには、Argo CDがResource Proxyに接続するための共有クライアント証明書が含まれます。

## 自動登録(Self-registration)の仕組み

Clusterリソースの`argocd-agent.walnuts.dev/enabled: "true"`ラベルをトリガーとして、共通のbootstrapコンポーネントがCAPI addon経由で以下を各ワークロードクラスタへ自動配布します。

- クライアント証明書とCAを含むSecret(`argocd-agent-client-tls`、`argocd-agent-ca`)
- Argo CD SpokeおよびAgentのHelmChartProxy
- Spokeが各種Secretを参照するためのRBACおよびExternalSecret(ServiceAccount、Role、RoleBinding、ClusterSecretStore、ExternalSecret)

Agentが有効なクライアント証明書でPrincipalへ接続すると、Principal側で`skip-reconcile`付きのcluster Secretが自動生成されます。以降、ApplicationSetが`berry`上に生成したApplicationは、Destinationベースで各Agentへ自動転送されます。

## 認証情報と暗号鍵の管理

PrincipalのJWT署名鍵は、`argocd-agent-jwt` Secretの`jwt.key`を使用します。
このSecretは、1PasswordのDocumentアイテム`argocd-agent-jwt`に保存された`jwt.key`ファイルからExternalSecretが同期します。

- 証明書の秘密鍵やJWT署名鍵はGitに保存しません。証明書はcert-manager、JWT署名鍵は1Passwordを信頼できる情報源(Source of Truth)とします。
- `allowGenerate`は無効化されています。通常運用で`argocd-agentctl jwt create-key`等を手動実行する必要はありません。

1Password側の鍵を更新した場合はExternalSecretの再同期を待った後、必要に応じてPrincipalやAgentを再起動します。

```bash
mise run argocd-agent:restart kurumi
mise run argocd-agent:restart biscuit
```

## 状態確認コマンド

クラスタやAgentの状態を確認する主なコマンドです。

```bash
# berry: PrincipalおよびSecretの状態確認
kubectl --context berry -n argocd get deployment argocd-agent
kubectl --context berry -n argocd get externalsecret/argocd-agent-jwt secret/argocd-agent-jwt
kubectl --context berry -n argocd get secret cluster-kurumi cluster-biscuit

# berry: 各ワークロードクラスタ向けCAPIリソースの状態確認
kubectl --context berry -n kurumi get helmchartproxy,clusterresourceset,externalsecret
kubectl --context berry -n biscuit get helmchartproxy,clusterresourceset,externalsecret

# 各ワークロードクラスタ: Spoke/Agent Podの稼働確認
kubectl --context kurumi -n argocd get pods
kubectl --context biscuit -n argocd get pods

```

主な確認項目は以下の通りです。

- Principal側でSelf-registrationラベル付きのcluster Secretが作成されていること
- ワークロードクラスタ内のSpokeおよびAgent PodがReadyになっていること
- Agentの接続ログにエラーが出力されていないこと
- 対象Applicationが`Synced`かつ`Healthy`になっていること

## トラブルシューティング

### `argocd-agent-jwt` Secretの欠落

- `berry`上のExternalSecretのステータスおよび`onepassword` ClusterSecretStoreの状態を確認してください。
- 1Password側に`argocd-agent-jwt`という名前のDocumentアイテムと`jwt.key`ファイルが存在するか確認してください。
- Secretをマニフェストに直接記述したり、Agent側の自動生成を有効にしたりして解決しないでください。

### JWT署名鍵のローテーション

ExternalSecretが新しい鍵を同期した後、`berry`上のPrincipalを再起動して鍵を再読み込みさせます。

```bash
kubectl --context berry -n argocd rollout restart deployment/argocd-agent
kubectl --context berry -n argocd rollout status deployment/argocd-agent --timeout=5m
```

### ワークロードクラスタのroot Secret未配布

- `berry`側の対象Namespace(`kurumi`や`biscuit`)で、`onepassword-bootstrap` ExternalSecretとClusterResourceSetのステータスを確認してください。
- ワークロードクラスタ側で手動作成せず、ClusterResourceSetの再同期を待つかトリガーしてください。

### Agent Podの起動失敗または接続不能

- 対象NamespaceのSpokeおよびAgent用HelmChartProxy、ならびにCAPI addon providerの状態を確認してください。
- `argocd-agent-client-tls`と`argocd-agent-ca`が正しく配布されているか確認してください(手動でTLS Secretをコピーしないでください)。
- ワークロードクラスタからPrincipalのエンドポイント(`argocd-agent.local.walnuts.dev:443`)への名前解決とTCP疎通が可能か確認してください。

### cluster Secretの自動登録失敗

- PrincipalおよびAgentのログを確認してください。
- クライアント証明書のSubjectや、Principal側の共有クライアント証明書の設定を確認してください。
- Clusterリソースに`argocd-agent.walnuts.dev/enabled: "true"`ラベルが付与されているか確認してください。
- `argocd-agentctl agent create`などによる手動登録は行わないでください。

### Applicationの同期失敗

以下の順で設定と状態を確認してください。

1. `berry`上のApplicationSetから意図したApplicationが生成されているか
2. AppProjectのdestination許可設定
3. Applicationに`argocd-agent=true`ラベルが付与されているか
4. AgentからResource Proxyへの接続状態
5. ワークロードクラスタ側の`application-controller`のログ
