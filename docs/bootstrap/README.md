# Bootstrap

物理マシンのクリーンインストール状態から管理クラスタ(`berry`)をセットアップし、GitOpsによる自動管理へ引き渡す(ハンドオフする)までの手順です。

(※既存クラスタや既存PV、Longhorn、SeaweedFSのデータ移行手順は含みません)

## 前提条件

- 管理クラスタ(`berry`)はRaspberry Pi OS上にセットアップします。
- 物理ホスト(`kurumi`/`biscuit`)は、各クラスタのドキュメント([kurumi](../clusters/kurumi.md)/[biscuit](../clusters/biscuit.md))に記載の物理要件(PXE、BMC/AMT/WoL、ディスク配線など)を設定済みである必要があります。
- 1PasswordのVault `kurumi`から、`berry`用のConnect root認証情報およびArgo CD AgentのJWT署名鍵が取得できる状態にしてください。JWT署名鍵はDocumentアイテム`argocd-agent-jwt`の`jwt.key`(PKCS#8 PEM形式)として保存されている必要があります。
- [docs/bootstrap/berry.md](./berry.md)で使用するroot Secret作成用ファイルとConnectトークンを手元に用意してください(機密情報はGitにコミットしないでください)。

## 手順

### 1. berryのセットアップ
[docs/bootstrap/berry.md](./berry.md)に従って、OS設定、ネットワーク、k3s、root Secret、Argo CDの初期セットアップを行います。

### 2. GitOpsへのハンドオフ
`berry`上でArgo CDが起動したら、以下のコマンドを1回だけ実行してベース設定を流し込みます。

```bash
kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
```

### 3. 自動収束の待機
これ以降の構築はArgo CDとGitOpsに任せます。Cluster API Operator、Tart provider、Cluster、Cilium、Argo CD Spoke/Agent、各ワークロードクラスタ用の1Password認証情報、ApplicationSet、各種アプリケーションなどは、すべてリポジトリの定義に従って自動的にデプロイ・収束します(1Passwordのroot認証情報は、Agent bootstrapと同様にCAPI addon経由で`onepassword-connect`起動前に自動配布されます)。

### 4. 完了確認
`berry`上のCAPIリソースおよびArgo CD Applicationのステータスを確認します。ワークロードクラスタに対して個別に`kubectl`や`helm`を実行したり、Secretの手動コピーやAgent CLIの実行を行ったりする必要はありません。

---

障害調査や証明書更新後のAgent再起動、Principalの状態確認などは[Argo CD Agent運用](../operations/argocd-agent.md)を参照してください。
