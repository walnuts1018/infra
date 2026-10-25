# Playground共有データのバックアップと復旧

`mcl-playground` SeaweedFSバケットは毎日03:17 JSTに非公開のB2バケットへコピーします。バックアップ用SeaweedFS資格情報は読み取り専用で、B2の専用Application Keyは対象バケットだけに読み書きできます。削除済みオブジェクトはB2で365日後に非表示となり、さらに30日後に削除されます。

PostgreSQLの共有メタデータは`mcl_playground`データベースにあります。SeaweedFSオブジェクトだけを戻しても共有URLは復旧しないため、復旧時は同じ時点のPostgreSQLバックアップも復元してください。PostgreSQLバックアップはCloudNativePGの既存バックアップ手順に従います。

## SeaweedFSバケットの復元

復旧作業中は共有APIのDeploymentを停止し、復旧用JobにB2バックアップ資格情報と`mcl-playground-s3-credentials`を渡します。B2側のExternalSecretにある`RCLONE_CONFIG_B2_ACCOUNT`と`RCLONE_CONFIG_B2_KEY`、SeaweedFS資格情報にある`AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`を設定します。

CronJobと同じrclone設定を使い、次の方向でコピーします。

```sh
rclone --config=/config/rclone.conf copy \
  b2:walnuts-mcl-playground-backup-81f18e5/mcl-playground \
  seaweed:mcl-playground \
  --transfers=4 --checkers=8 --b2-chunk-size=64M
```

PostgreSQLを対応するバックアップへ復元した後、共有APIを起動し、共有URLから複数ファイルのスナップショットを取得できることを確認します。
