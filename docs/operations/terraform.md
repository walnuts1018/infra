# Terraform運用ガイド

## SeaweedFS(biscuit)のライフサイクル分離

`biscuit`のSeaweedFSはクラスタ起動後にデプロイされる単一Podで、bucketとlifecycleの作成にはSeaweedFS endpointへのS3接続が必要です。そのため、外部インフラとcluster bootstrapをPhase 1、SeaweedFS内のS3 resourceをPhase 2として分離します。

### Phase 1 外部インフラと1Passwordのseed

クラスタbootstrapより前に、`manage_biscuit_seaweedfs = false`でTerraformをapplyします。このapplyで外部インフラと1Password item`terraform-external-secrets`を作成し、biscuitのExternal Secretsが参照するcredentialをseedします。

`manage_biscuit_seaweedfs`が`false`でも、AWS providerと1Password moduleが変数を参照するため、次のbiscuit用Terraform S3 credentialは必須です。

```
export TF_VAR_seaweedfs_biscuit_terraform_access_key=...
export TF_VAR_seaweedfs_biscuit_terraform_secret_key=...
```

その他のTerraform必須変数を設定したうえで、同じworkspaceから`terraform apply`を実行します。

### Phase 2 SeaweedFS resource

berry、CAPI、Argo CD Agentが同期し、biscuitのSeaweedFSが`Ready`になった後に、`manage_biscuit_seaweedfs = true`へ変更して同じworkspaceで`terraform apply`を実行します。ここでSeaweedFSのbucketとlifecycleを作成します。

このPhase 2はcluster起動後に必要なTerraform操作です。bootstrap途中でapplyを停止したり、Kubernetesの状態確認後に同じapplyを再実行したりする手順はありません。

将来SeaweedFS OperatorのBucket CRで安全に管理できる範囲が明確になった場合は、Phase 2をGitOpsへ移行できます。
