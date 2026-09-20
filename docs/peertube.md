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

rootでログインした後、管理画面から通常ユーザーを作成してください。signupは無効のままです。

## Remote Runner

Runner registration tokenはPeerTube APIからRunner起動時に取得します。PeerTube側でtokenが存在しない場合だけAPIで生成し、RunnerのLonghorn領域へ保存します。Terraformや1Passwordでtokenを生成・管理しません。
