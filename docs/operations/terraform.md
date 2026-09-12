# Terraform 運用ガイド

## SeaweedFS (biscuit) のライフサイクル分離

本環境の Terraform 管理では、通常時の実行変数として `manage_biscuit_seaweedfs = false` を設定しています。  
これにより、AWS、Backblaze B2、Cloudflare、ZITADEL、1Password などの外部インフラ管理を、biscuit クラスタ上の SeaweedFS エンドポイントへの接続を伴わずに安全に実行できます。

### 分離している背景

`biscuit` クラスタの SeaweedFS は、クラスタ起動後にデプロイされる単一 Pod 構成です。  
現在、バケットの作成には SeaweedFS Operator の Bucket CR ではなく、S3 API を叩く Terraform モジュールを採用しています。そのため、biscuit クラスタおよび SeaweedFS が正常に稼働（Ready）していない段階では、これらのリソースを作成できません。

### 初回構築時（Post-bootstrap）の手順

クラスタの初回ブートストラップ（berry のセットアップ、CAPI、Argo CD Agent の同期）完了後、SeaweedFS が Ready になったことを確認してから以下の手順を行います。

1. Terraform ワークスペースの変数で `manage_biscuit_seaweedfs = true` に変更・設定する。
2. 同一ワークスペースで `terraform apply` を実行する。

※ クラスタ起動前の `apply` 途中で一時停止して手動でクラスタ状態を確認するような不安定な運用を避けるため、初回ブートストラップ処理とは明示的にフェーズを分けています。  
※ 将来的に SeaweedFS Operator がこの構成におけるバケットやライフサイクルポリシーを宣言的に安全管理できるようになれば、本 Terraform モジュールは廃止し、GitOps 側へ移行する予定です。
