# Terraform運用ガイド

## SeaweedFS(biscuit)のライフサイクル分離

本環境のTerraform管理では、通常時の実行変数として`manage_biscuit_seaweedfs = false`を設定しています。
これにより、AWS、Backblaze B2、Cloudflare、ZITADEL、1Passwordなどの外部インフラ管理を、biscuitクラスタ上のSeaweedFSエンドポイントへの接続を伴わずに安全に実行できます。

### 分離の背景

`biscuit`クラスタのSeaweedFSは、クラスタ起動後にデプロイされる単一Pod構成です。
現在、バケットの作成にはSeaweedFS OperatorのBucket CRではなく、S3 APIを叩くTerraformモジュールを採用しています。そのため、biscuitクラスタおよびSeaweedFSが正常に稼働(Ready)していない段階では、これらのリソースを作成できません。

### 初回構築時(Post-bootstrap)の手順

クラスタの初回ブートストラップ(`berry`のセットアップ、CAPI、Argo CD Agentの同期)完了後、SeaweedFSがReadyになったことを確認してから以下の手順を行います。

1. Terraformワークスペースの変数で`manage_biscuit_seaweedfs = true`に変更・設定する。
2. 同一ワークスペースで`terraform apply`を実行する。

(※クラスタ起動前の`apply`途中で一時停止して手動でクラスタ状態を確認するような不安定な運用を避けるため、初回ブートストラップ処理とは明示的にフェーズを分けています)
(※将来的にSeaweedFS Operatorがこの構成におけるバケットやライフサイクルポリシーを宣言的に安全管理できるようになれば、本Terraformモジュールは廃止し、GitOps側へ移行する予定です)
