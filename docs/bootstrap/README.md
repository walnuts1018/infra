# Bootstrap

物理マシンのクリーンインストール状態から管理クラスタ（`berry`）をセットアップし、GitOpsによる自動管理へ引き渡す（ハンドオフする）までの手順です。

※ 既存クラスタや既存PV、Longhorn、SeaweedFSのデータ移行手順は含みません。

## 前提条件

- **管理クラスタ (`berry`)**: Raspberry Pi OS 上にセットアップします。
- **物理ホスト (`kurumi` / `biscuit`)**: 各クラスタのドキュメント（[kurumi](../clusters/kurumi.md) / [biscuit](../clusters/biscuit.md)）に記載の物理要件（PXE、BMC / AMT / WoL、ディスク配線など）を設定済みであること。
- **1Password**: 
  - Vault `kurumi` から、`berry` 用の Connect root 認証情報および Argo CD Agent の JWT 署名鍵が取得できる状態であること。
  - JWT 署名鍵は、Document アイテム `argocd-agent-jwt` の `jwt.key`（PKCS#8 PEM形式）として保存されている必要があります。
- **シークレット準備**:
  - `docs/bootstrap/berry.md` で使用する root Secret 作成用ファイルと Connect トークンを手元に用意してください（※機密情報はGitにコミットしないでください）。

## 手順

1. **berry のセットアップ**  
   [docs/bootstrap/berry.md](./berry.md) に従って、OS設定、ネットワーク、k3s、root Secret、Argo CD の初期セットアップを行います。

2. **GitOps へのハンドオフ**  
   `berry` 上で Argo CD が起動したら、以下のコマンドを1回だけ実行してベース設定を流し込みます。

   ```bash
   kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
   ```

3. **自動収束の待機**  
   これ以降の構築は、Argo CD と GitOps に任せます。  
   Cluster API Operator、Tart provider、Cluster、Cilium、Argo CD Spoke / Agent、各ワークロードクラスタ用の 1Password 認証情報、ApplicationSet、各種アプリケーションなどは、すべてリポジトリの定義に従って自動的にデプロイ・収束します。  
   （※ 1Password の root 認証情報は、Agent bootstrap と同様に CAPI addon 経由で `onepassword-connect` 起動前に自動配布されます）

4. **完了確認**  
   `berry` 上の CAPI リソースおよび Argo CD Application のステータスを確認します。ワークロードクラスタに対して個別に `kubectl` や `helm` を実行したり、Secret の手動コピーや Agent CLI の実行を行ったりする必要はありません。

---

障害調査や証明書更新後の Agent 再起動、Principal の状態確認などは [Argo CD Agent運用](../operations/argocd-agent.md) を参照してください。

