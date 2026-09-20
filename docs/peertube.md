# PeerTube初回セットアップ

PeerTubeは公式イメージの通常起動を使用します。DB schema migrationやversion固有のmanual migration、pluginのインストールをDeploymentの起動処理には含めません。

## 初回処理

Argo CDでPeerTubeを同期し、DeploymentがReadyになった後に8.3のmanual migrationを一度だけ実行します。

```sh
kubectl -n peertube exec deploy/peertube -- \
  node dist/scripts/migrations/peertube-8.3.js
```

PeerTubeの通常DB migrationは、以後の通常起動時にPeerTube自身が実行します。将来のアップグレードでmanual migrationが要求された場合だけ、対象リリースの手順に従って明示的に実行します。

## ログイン

外部からのHTTPアクセスはEnvoy GatewayのZITADEL OIDC filterで保護されます。PeerTube内部のログインは通常のPeerTubeユーザー名・パスワードを使用します。初期rootパスワードは`peertube-secrets`のExternalSecretから生成されたSecretに保存されています。

```sh
secret_name="$(kubectl -n peertube get externalsecret peertube-secrets -o jsonpath='{.spec.target.name}')"
kubectl -n peertube get secret "${secret_name}" -o jsonpath='{.data.admin-password}' | base64 -d
```

ZITADELの`peertube-user`ロールを持つユーザーだけがEnvoy Gatewayを通過できます。PeerTubeのsignupは有効にしているため、各ユーザーが初回アクセス時にPeerTube用のローカルパスワードを設定できます。

## Remote Runner

Runnerは`images/peertube-runner`でビルドした公式`@peertube/peertube-runner`イメージを使用します。initContainerの`bootstrap.mjs`がPeerTube APIでregistration tokenとrunner tokenを取得し、Longhornにはrunner設定だけを保存します。FFmpegのtranscoding作業領域とIPC領域は`emptyDir`です。Terraformや1Passwordでtokenを生成・管理しません。
