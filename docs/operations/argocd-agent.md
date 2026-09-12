# Argo CD Agent 運用ガイド

## アーキテクチャ概要

本環境では、Argo CD Agent を用いたマルチクラスタ構成を採用しています。

- **管理クラスタ (`berry`)**:  
  Argo CD Principal、ApplicationSet、cert-manager、External Secrets Operator を実行します。
- **ワークロードクラスタ (`kurumi`, `biscuit`)**:  
  Argo CD Spoke、application-controller、repo-server、Redis、Argo CD Agent を実行し、Application の実リソースは各ワークロードクラスタ内で Reconcile されます。

ワークロードクラスタへの Spoke や Agent のデプロイは、CAPI の ClusterResourceSet および HelmChartProxy により自動で行われます。

Agent は `argocd-agent.local.walnuts.dev:443` 経由で Principal に接続します。通信に必要な mTLS 証明書（Principal 証明書、CA、各ワークロードクラスタ用のクライアント証明書）は、すべて `berry` 上の cert-manager が発行・管理します。  
また、Principal がクラスタ自動登録（Self-registration）時に生成する cluster Secret には、Argo CD が Resource Proxy に接続するための共有クライアント証明書が含まれます。

## 自動登録（Self-registration）の仕組み

Cluster リソースの `argocd-agent.walnuts.dev/enabled: "true"` ラベルをトリガーとして、共通の bootstrap コンポーネントが CAPI addon 経由で以下を各ワークロードクラスタへ自動配布します。

- クライアント証明書と CA を含む Secret（`argocd-agent-client-tls`, `argocd-agent-ca`）
- Argo CD Spoke および Agent の HelmChartProxy
- Spoke が各種 Secret を参照するための RBAC および ExternalSecret（ServiceAccount, Role, RoleBinding, ClusterSecretStore, ExternalSecret）

Agent が有効なクライアント証明書で Principal へ接続すると、Principal 側で `skip-reconcile` 付きの cluster Secret が自動生成されます。以降、ApplicationSet が `berry` 上に生成した Application は、Destination ベースで各 Agent へ自動転送されます。

## 認証情報・暗号鍵の管理

Principal の JWT 署名鍵は、`argocd-agent-jwt` Secret の `jwt.key` を使用します。  
この Secret は、1Password の Document アイテム `argocd-agent-jwt` に保存された `jwt.key` ファイルから ExternalSecret が同期します。

- **Git 非保持の原則**: 証明書の秘密鍵や JWT 署名鍵は Git に保存しません。証明書は cert-manager、JWT 署名鍵は 1Password を信頼できる情報源（Source of Truth）とします。
- **手動生成の禁止**: `allowGenerate` は無効化されています。通常運用で `argocd-agentctl jwt create-key` 等を手動実行する必要はありません。

1Password 側の鍵を更新した場合は ExternalSecret の再同期を待った後、必要に応じて Principal や Agent を再起動します。

```bash
mise run argocd-agent:restart kurumi
mise run argocd-agent:restart biscuit
```

## 状態確認コマンド

クラスタや Agent の状態を確認する主なコマンドです。

```bash
# berry: Principal および Secret の状態確認
kubectl --context berry -n argocd get deployment argocd-agent
kubectl --context berry -n argocd get externalsecret argocd-agent-jwt secret argocd-agent-jwt
kubectl --context berry -n argocd get secret cluster-kurumi cluster-biscuit

# berry: 各ワークロードクラスタ向け CAPI リソースの状態確認
kubectl --context berry -n kurumi get helmchartproxy,clusterresourceset,externalsecret
kubectl --context berry -n biscuit get helmchartproxy,clusterresourceset,externalsecret

# 各ワークロードクラスタ: Spoke / Agent Pod の稼働確認
kubectl --context kurumi -n argocd get pods
kubectl --context biscuit -n argocd get pods
```

確認ポイント:

- Principal 側で Self-registration ラベル付きの cluster Secret が作成されているか
- ワークロードクラスタ内の Spoke / Agent Pod が Ready になっているか
- Agent の接続ログにエラーがないか
- 対象 Application が `Synced` かつ `Healthy` になっているか

## トラブルシューティング

### `argocd-agent-jwt` Secret が存在しない

- `berry` 上の ExternalSecret のステータスおよび `onepassword` ClusterSecretStore の状態を確認してください。
- 1Password 側に `argocd-agent-jwt` という名前の Document アイテムと `jwt.key` ファイルが存在するか確認してください。
- ※ Secret をマニフェストにベタ書きしたり、Agent 側の自動生成を有効にしたりして解決しないでください。

### JWT 署名鍵をローテーションした場合

ExternalSecret が新しい鍵を同期した後、`berry` 上の Principal を再起動して鍵を再読み込みさせます。

```bash
kubectl --context berry -n argocd rollout restart deployment/argocd-agent
kubectl --context berry -n argocd rollout status deployment/argocd-agent --timeout=5m
```

### ワークロードクラスタに `onepassword` Namespace や root Secret が存在しない

- `berry` 側の対象 Namespace（`kurumi` や `biscuit`）で、`onepassword-bootstrap` ExternalSecret と ClusterResourceSet のステータスを確認してください。
- ワークロードクラスタ側で手動作成せず、ClusterResourceSet の再同期を待つかトリガーしてください。

### Agent Pod が起動しない / 接続できない

- 対象 Namespace の Spoke / Agent 用 HelmChartProxy および CAPI addon provider の状態を確認してください。
- `argocd-agent-client-tls` と `argocd-agent-ca` が正しく配布されているか確認してください（※手動で TLS Secret をコピーしないでください）。
- ワークロードクラスタから Principal のエンドポイント（`argocd-agent.local.walnuts.dev:443`）への名前解決と TCP 疎通が可能か確認してください。

### cluster Secret が Self-registration されない

- Principal および Agent のログを確認してください。
- クライアント証明書の Subject や、Principal 側の共有クライアント証明書の設定を確認してください。
- Cluster リソースに `argocd-agent.walnuts.dev/enabled: "true"` ラベルが付与されているか確認してください。
- ※ `argocd-agentctl agent create` などで手動登録は行わないでください。

### Application が同期（Sync）されない

以下の順で設定と状態を確認してください。

1. `berry` 上の ApplicationSet から意図した Application が生成されているか
2. AppProject の destination 許可設定
3. Application に `argocd-agent=true` ラベルが付与されているか
4. Agent から Resource Proxy への接続状態
5. ワークロードクラスタ側の `application-controller` のログ
