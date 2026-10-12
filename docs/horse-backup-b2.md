# Horseバックアップ用B2

Horse専用のprivate bucket `walnuts-horse-backup-81f18e5`を作成するTerraform案です。既存の`walnuts-minio-biscuit-backup-81f18e5` bucket、既存key、既存lifecycle ruleには変更を加えません。

新bucketはSSE-B2を既定にし、Object LockのGovernance retentionを30日間に設定します。Object Lock有効化後はbucketで無効化できません。RetentionはObject Lock権限を持つ管理者が見直せますが、Horseのwriter keyには`bypassGovernance`も`writeFileRetentions`も付けません。Lifecycleは`horse/` prefixのobjectを30日後にhideし、hideから7日後に削除します。Object Lockによりアップロード後30日間は上書きと削除を拒否します。Lifecycle処理を含む削除完了はおおむね37日後です。

Terraformは`horse/` prefixに制限したwriter keyとreader keyを別々に作成し、secret値を`horse-backup` OnePassword itemへ保存します。writer keyには`listFiles`、`readFiles`、`writeFiles`を付け、`deleteFiles`とbucket管理権限は付けません。reader keyは`listFiles`と`readFiles`だけを持ちます。B2の`writeFiles`にはhide操作も含まれますが、Governance retention中のobjectはHorseのkeyでは削除できません。retention終了後の保持はLifecycleの規則に従います。

このTerraform案はbucket/key/OnePassword itemを作る構成までで、Kubernetes Secret、CloudNativePG backup設定、復元jobはまだ接続しません。利用開始前に1KB程度の合成objectを`horse/validation/`へ保存し、SSE-B2、Object Lock、prefix制限付きwriter/reader keyの読み書きを確認します。検証objectもGovernance retentionが終了するまで削除できません。検証後にのみCNPG backup設定を接続し、本番DBと原本objectを含む復元検証を計画します。

Backblazeの公開価格は$6.95/TB/30日です。最初の10GBは無料で、月間平均保存量の3倍までegressが無料です。1TBを30日保存した場合のstorage料金は約$6.95で、transactionやegressの条件は[公式料金表](https://www.backblaze.com/cloud-storage/pricing)を参照してください。Object Lockは30日分の削除不能期間を作るため、削除を予定するbackupにも最低30日の保存料金が発生します。

Terraform providerのbucket encryption、Object Lock、application key capability設定は[Backblaze B2 provider](https://registry.terraform.io/providers/Backblaze/b2/latest/docs/resources/bucket)と[application key仕様](https://www.backblaze.com/docs/cloud-storage-application-key-capabilities)に基づきます。Object Lockは[Backblaze公式資料](https://www.backblaze.com/docs/cloud-storage-object-lock)に従い、新bucketにのみ有効化します。
