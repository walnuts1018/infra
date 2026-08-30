# SeaweedFS filerメタデータのTiKV移行Runbook

このRunbookはSeaweedFSのVolumeデータを動かさず、filerメタデータだけをScyllaDBおよびPostgreSQLから`tikv-cluster`へ停止移行する手順を定める。移行中はS3 APIを停止し、移行元DBと退避ファイルは最終検証が終わるまで保持する。

## 適用順序

変更は次の3コミットへ分割する。第2コミットはメタデータの保存と復元が完了するまでpushしない。

1. TiDB Operator、CRD Application、`tikv-cluster`、TLS Certificate、SeaweedFSの`4.44_large_disk_full`イメージだけを導入する。SeaweedFSのfilerストアとScyllaDB用mountは変更しない。
2. `filer.toml`をTiKVへ切り替え、SeaweedFSのTiKVクライアント証明書をmountし、ScyllaDB用mountと旧DB認証情報を削除する。
3. 移行後の全検証が成功してから、ScyllaDBとPostgreSQLにあるSeaweedFS専用の宣言を削除する。

## 事前確認

第1コミットのsync後に次を確認する。

- `tidb-operator` DeploymentがAvailableである。
- PDとTiKVが各3 Pod Readyで、各Podが異なる`kubernetes.io/hostname`へ配置されている。
- PD leaderが存在し、3つのTiKV storeがUpである。
- PD 1GiとTiKV 8Giの各PVCがBoundで、PVのreclaim policyがRetainである。
- `tikv-cluster-pd-cluster-secret`、`tikv-cluster-tikv-cluster-secret`、`tikv-cluster-cluster-client-secret`、`seaweedfs-tikv-client`がReadyなCertificateから発行されている。
- SeaweedFSが`4.44_large_disk_full`で起動し、旧メタデータDBを使ったS3 PUT、GET、DELETEが成功する。

TiKVのprefixは`<application>/<instance>/`形式で割り当てる。`seaweedfs-default/`はこのSeaweedFS専用であり、別用途へ再利用しない。TiKVはクライアント証明書ごとのprefix認可を提供しないため、相互に信頼できない利用者は別クラスターへ分離する。

## 停止と退避

1. Argo CD Applicationの`seaweedfs-default`、`seaweedfs-operator`、`seaweedfs-operator-helm`から自動syncを一時的に外し、対象が意図せず再作成されないことを確認する。
2. SeaweedFS Operatorを0レプリカへ縮退し、Seaweed CRから生成されたfiler StatefulSetを0レプリカへ縮退する。MasterとVolumeは停止しない。
3. S3 ServiceのEndpointSliceにfiler Endpointが残っていないことを確認する。Endpointが残る場合は移行を開始しない。
4. 第1コミット時点のfiler設定、IAM設定、旧DBのCAおよびクライアント証明書をmountした一時Podを`seaweedfs` Namespaceへ作成する。通常Serviceのselectorと一致するlabelを付けず、外部トラフィックを受けないようにする。
5. 一時Podで`weed shell`を起動し、`fs.meta.save -v=false -o=/tmp/source.meta.gz /`を実行する。
6. `source.meta.gz`をローカルのアクセス制限された退避先へコピーする。`gzip -dc source.meta.gz | sha256sum`で非圧縮SHA-256を記録し、`fs.meta.save`の出力からディレクトリ数とファイル数も記録する。

## TiKVへの復元

1. 第2コミットの`filer.toml`、IAM設定、`seaweedfs-tikv-client` Secretをmountした別の一時Podを作成する。このPodにも通常Serviceのselectorと一致するlabelを付けない。
2. `source.meta.gz`を一時Podへコピーし、`weed shell`から`fs.meta.load -v=false -concurrency=8 /tmp/source.meta.gz`を実行する。
3. 復元先で`fs.meta.save -v=false -o=/tmp/destination.meta.gz /`を実行し、ローカルへコピーする。
4. 移行元と移行先についてディレクトリ数、ファイル数、`gzip -dc FILE | sha256sum`の結果を比較する。1項目でも一致しない場合は切り替えない。
5. 一致した場合だけ第2コミットをpushし、停止中の`seaweedfs-default`を手動syncする。その後SeaweedFS Operatorを再開し、filer 2 PodがReadyになることを確認する。
6. 3つのApplicationの自動syncを元へ戻し、Seaweed CR、filer Pod、ExternalSecret、Certificate、Service、EndpointSliceがSyncedかつHealthyへ収束することを確認する。

## 切り替え後の検証

- 削除を許可されていない全非空Bucketについて代表オブジェクトのHEADとRange GETを実行する。少なくとも`picca`、`misskey`、`cloudnative-pg-backup`、`netbox-media`、`stalwart`、`loki-chunks`、`tempo`を個別に記録する。
- 専用の一時prefixへS3 PUT、GET、DELETEを実行し、新しい変更を再起動後も読み書きできることを確認する。
- `volume.fsck`を削除無効のdry-runで実行し、TiKVメタデータが参照するchunkの欠落がないことを確認する。
- filerログにTiKV接続エラー、TLS検証エラー、永続化エラーがないことを確認する。
- PD leader、全TiKV storeのUp、PodとPVCの健全性、主要利用アプリのエラー率を確認する。

検証に失敗した場合は旧DBを削除しない。第2コミットをrevertし、旧設定を手動syncしてfilerを再起動する。切り替え中にTiKVへ新規書き込みが発生していた場合は、その差分の扱いを決めてからロールバックする。

## 旧DBの削除

全検証の成功後だけ第3コミットを作成する。

1. ScyllaDB migrationから`seaweedfs` keyspace、`seaweedfs` role、関連するSecret参照を削除する。
2. PostgreSQLから`seaweedfs_loki_chunks` Database、`seaweedfs` managed role、関連するExternalSecretを削除する。
3. 第3コミットをpushしてsyncし、宣言的な再作成経路がなくなったことを確認する。
4. ScyllaDBで対象roleの権限と接続を確認してから、`seaweedfs` keyspaceと`seaweedfs` roleだけをDROPする。
5. PostgreSQLで依存関係と接続がないことを確認してから、`seaweedfs_loki_chunks` databaseと`seaweedfs` roleだけをDROPする。
6. 他のkeyspace、database、role、ScyllaDBクラスター、PostgreSQLクラスターには触れない。
7. TiKVから全Bucketを再確認し、旧DBにSeaweedFS関連データが残っていないことを確認する。退避した`source.meta.gz`はこの確認が終わるまで削除しない。

## 静的検証

各コミットで次を実行する。

```console
mise run jsonnet-fmt-check
mise run snapshot
mise run lint
git diff --check
```

生成snapshotではTiDB Operator、CRD Application、`tikv-cluster` TidbCluster、4つのCertificate、Seaweed CR、ExternalSecretを確認する。Secretの実値をManifest、コマンド履歴、移行記録へ出力しない。
