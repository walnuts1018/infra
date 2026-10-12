# SeaweedFS SSE-S3の鍵管理

SeaweedFSのSSE-S3はKEKでオブジェクトごとのDEKを保護します。S3 APIサーバーがKEKを失うと暗号化済みオブジェクトを復号できません。`WEED_S3_SSE_KEK`にはTerraformの`random_id`で生成した32バイトの値を64文字の16進数で渡します。Terraformはこの値を`seaweedfs-sse`のOnePassword itemに保存し、External Secrets OperatorがSeaweedFS namespaceのSecretへ同期します。すべてのS3 replicaは同じSecret keyを参照します。

HorseのS3 principalはHorse bucket内のobjectに対する`s3:GetObject`と`s3:PutObject`だけを許可します。Horseは新規Putに`x-amz-server-side-encryption: AES256`と条件付き作成を指定し、`DeleteObject`、`ListBucket`、multipart uploadを使用しません。SeaweedFSはSSEヘッダーのない既存アプリケーション要求にSSEを強制しないため、他のS3利用者のPut動作はこの変更で変わりません。Horseの条件付き作成は同じkeyの通常の上書きを避けますが、S3 IAMでは条件ヘッダーの指定を強制していないため、書込権限を持つ主体による上書きを完全には防ぎません。

`random_id.kek`とOnePassword itemにはTerraformの`prevent_destroy`を設定しています。KEKの値をログ、チケット、plan出力、CI artifact、手元のファイルへコピーしないでください。暗号化した原本を保持する期間はOnePassword itemとHCP Terraform workspaceのstate versionを保持してください。1PasswordはVaultとitemを日次バックアップし、itemの以前のバージョンを復元できます。Vault自体を削除すると復旧できないため、`seaweedfs-sse` itemと所属Vaultを削除しないでください。詳細は[1Passwordのバックアップ](https://support.1password.com/backups/)と[以前のitemの復元](https://support.1password.com/item-history-teams/)を参照してください。KEKのローテーションを通常のTerraform変更として行わないでください。SeaweedFSのSSE-S3メタデータは鍵の世代を識別できないため、異なるKEKへの置換は既存オブジェクトを読めなくする可能性があります。詳細は[SeaweedFSのSSE仕様](https://github.com/seaweedfs/seaweedfs/wiki/Server-Side-Encryption)を参照してください。

## 障害復旧

1. Terraform applyを停止し、OnePassword itemとHCP Terraformのworkspace stateを削除・置換しないでください。
2. `seaweedfs-sse` itemが変更・削除された場合は、1Passwordのitem historyまたはRecently Deletedから元のitem versionを復元します。Vault自体が削除された場合は1Passwordサポートへ相談し、復旧できるまでapplyを再開しません。HCP Terraform管理者は障害前の該当state versionを復元します。どちらか一方しか復旧できない場合はapplyを再開せず、同じKEKを保有する独立バックアップを探してください。
3. Secretの値を表示せずExternalSecretの`Ready=True`を確認します。S3 Deploymentの全replicaが同じSecretの`kek` keyを参照していることと、PodがReadyであることを確認します。
4. filer metadataとvolume dataを整合するSeaweedFS backupから復元します。SSE-S3 objectの復元先も保存時と同じKEKを使用します。
5. 本番bucket外の名前付き検証bucketに合成データをPutし、SSE-S3を指定したPUTの成功、`HeadObject`の`AES256`応答、復旧またはS3 Pod切替後のGET内容とSHA-256一致を確認します。鍵値、原本データ、認証情報をログに記録しません。
6. HorseについてはDB backupも同じ復旧時点へ戻し、DB内の原本keyがS3 object keyと一致し、各objectを取得したSHA-256がDB記録と一致することを確認します。検証bucketと名前付き検証objectは検証後に保持し、既存データを上書き・削除しません。

Terraform stateまたはOnePassword itemを復旧できないとき、Terraformの新しい`random_id`値でOnePassword itemを更新してはいけません。元のKEKを見つけるまでSSE objectは復旧不能として扱い、暗号化objectを上書き・移行しません。
