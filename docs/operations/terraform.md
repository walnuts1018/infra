# Terraform運用ガイド

## Workspace構成

Terraform Cloudでは`infra`、`seaweedfs-default`、`seaweedfs-biscuit`の3workspaceを使用します。既存の`terraform/`は`infra`workspaceのworking directoryとして維持し、SeaweedFS用のrootは`terraform/workspaces/`へ配置します。4つ目の`cloud`workspaceは作成しません。

`infra`workspaceはTerraform Cloudのremote executionで外部インフラ、1Password、Terraform Cloud自身を管理します。`seaweedfs-default`workspaceはkurumi上のAgent Pool`home`を使ってkurumiのSeaweedFS STSに接続し、bucket policyとCORSを管理します。`seaweedfs-biscuit`workspaceも同じAgent Poolを使い、biscuitのS3 credentialでbucket、versioning、lifecycle、multipart cleanupを管理します。

通常の変更では`infra`workspaceのapplyが下流workspaceのinitial runまたはrun triggerをqueueします。`tfe_workspace_run`は`wait_for_run = false`なので、`infra`workspaceのapplyは下流workspaceの完了を待ちません。下流runの待機や成功確認はTerraform Cloudと各clusterの状態を別に確認します。

## Credential管理

SeaweedFS biscuit用Terraform credentialは`infra`workspaceの`random_id`と`random_password`で生成され、1Password item`terraform-external-secrets`と`seaweedfs-biscuit`workspaceのsensitive variableへ同じ値が保存されます。手入力のcredentialは使用しません。

Terraform Cloud Agent Pool`home`とAgent tokenも`infra`workspaceで作成します。tokenは同じ1Password itemの`terraform_cloud_agent_token`として保存され、kurumiの`terraform-cloud-agent`DeploymentはExternalSecret経由で`TFC_AGENT_TOKEN`へ読み込みます。Secretが更新されるとReloaderがDeploymentを再起動します。

AWS IAMのVariable Setは`infra`workspaceだけに割り当てます。SeaweedFS STSのVariable Setは`seaweedfs-default`workspaceだけに割り当てます。Agent Poolはorganization-wideにせず、2つのSeaweedFS workspaceだけを許可します。

## State移行

State移行は、既存の`infra`workspaceを操作できる担当者が主導します。以下の手順はresourceを削除せずにstateの管理先だけを変更するためのものです。Terraform Cloudのrun、state version、SeaweedFS endpointの状態を確認できないまま進めないでください。

### 事前確認

1. Terraform Cloudの`infra`、`seaweedfs-default`、`seaweedfs-biscuit`に実行中のrunがないことを確認し、webhookによる新しいrunを一時的に止めます。
2. Terraform CloudのState Versionsから現在の`infra` stateをbackupします。加えて、次のコマンドでstateを取得し、アクセス権を絞った場所へ保存します。

    ```bash
    umask 077
    terraform -chdir=terraform state pull > /secure/path/infra-state-$(date +%Y%m%d-%H%M%S).json
    ```

3. 現在のstateに残っているSeaweedFS resourceを確認します。

    ```bash
    terraform -chdir=terraform state list | rg '^module\.seaweedfs\[0\]\.'
    ```

4. 新しい3 rootをcheckoutしたcommitで、下記の一時`import` blockを各workspaceのrootへ追加します。`infra`のapplyがqueueするinitial runがこのcommitを実行できるよう、state操作より先に準備します。

### 旧stateからの除去

stateからの除去はresourceのremote objectを削除しません。対象addressを`terraform state list`の結果と照合してから、次の旧addressだけを`infra` stateから除去します。

```bash
terraform -chdir=terraform state rm \
  'module.seaweedfs[0].aws_s3_bucket_policy.public_read["misskey"]' \
  'module.seaweedfs[0].aws_s3_bucket_policy.public_read["oekaki-dengon-game"]' \
  'module.seaweedfs[0].aws_s3_bucket_cors_configuration.this["picca"]' \
  'module.seaweedfs[0].aws_s3_bucket_cors_configuration.this["picca-dev"]' \
  'module.seaweedfs[0].aws_s3_bucket.biscuit_cloudnative_pg_backup' \
  'module.seaweedfs[0].aws_s3_bucket.biscuit_longhorn_backup' \
  'module.seaweedfs[0].aws_s3_bucket.biscuit_seaweedfs_default_backup' \
  'module.seaweedfs[0].aws_s3_bucket.biscuit_velero_backup' \
  'module.seaweedfs[0].aws_s3_bucket_versioning.biscuit_backup["cloudnative_pg"]' \
  'module.seaweedfs[0].aws_s3_bucket_versioning.biscuit_backup["longhorn"]' \
  'module.seaweedfs[0].aws_s3_bucket_versioning.biscuit_backup["seaweedfs"]' \
  'module.seaweedfs[0].aws_s3_bucket_versioning.biscuit_backup["velero"]' \
  'module.seaweedfs[0].aws_s3_bucket_lifecycle_configuration.biscuit_app_managed_backup["cloudnative_pg"]' \
  'module.seaweedfs[0].aws_s3_bucket_lifecycle_configuration.biscuit_app_managed_backup["longhorn"]' \
  'module.seaweedfs[0].aws_s3_bucket_lifecycle_configuration.biscuit_app_managed_backup["seaweedfs"]' \
  'module.seaweedfs[0].aws_s3_bucket_lifecycle_configuration.biscuit_app_managed_backup["velero"]'
```

現在の`desired-state.json`ではpublic policyの対象は`misskey`と`oekaki-dengon-game`の2つです。state listに対象外のpolicyが残っている場合は、上のコマンドへ追加してから実行します。現行ファイルとstateのresource数が一致しない場合は、state rmを中断して差分を調査します。

過去のpublic policy設定から`picca`のpolicyが旧stateに残っている場合があります。現行moduleには`picca`のpolicy addressがないため、推測したimport先へ移さずに停止し、`desired-state.json`へ設定を戻して管理を継続するか、remote policyを別手順で整理するかを決めます。

実行後に次の結果を確認します。

```bash
terraform -chdir=terraform state list | rg '^module\.seaweedfs\[0\]\.'
```

何も出力されなければ、remote bucketやpolicyを削除せず旧`infra` stateからの除去が完了しています。出力が残る場合はその場で停止し、残ったaddressを確認します。

### 一時import block

`terraform/workspaces/seaweedfs-default/import.tf`に次を追加します。policyの対象は現行の`desired-state.json`に合わせてください。

```hcl
import {
  to = module.seaweedfs_default.aws_s3_bucket_policy.public_read["misskey"]
  id = "misskey"
}

import {
  to = module.seaweedfs_default.aws_s3_bucket_policy.public_read["oekaki-dengon-game"]
  id = "oekaki-dengon-game"
}

import {
  to = module.seaweedfs_default.aws_s3_bucket_cors_configuration.this["picca"]
  id = "picca"
}

import {
  to = module.seaweedfs_default.aws_s3_bucket_cors_configuration.this["picca-dev"]
  id = "picca-dev"
}
```

`terraform/workspaces/seaweedfs-biscuit/import.tf`には4 bucket、4 versioning、4 lifecycleを追加します。`aws_s3_bucket`、`aws_s3_bucket_versioning`、`aws_s3_bucket_lifecycle_configuration`のimport idはいずれもbucket名です。

```hcl
import {
  to = module.seaweedfs_biscuit.aws_s3_bucket.cloudnative_pg_backup
  id = "cloudnative-pg-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket.longhorn_backup
  id = "longhorn-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket.seaweedfs_default_backup
  id = "seaweedfs-default-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket.velero_backup
  id = "velero-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_versioning.backup["cloudnative_pg"]
  id = "cloudnative-pg-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_versioning.backup["longhorn"]
  id = "longhorn-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_versioning.backup["seaweedfs"]
  id = "seaweedfs-default-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_versioning.backup["velero"]
  id = "velero-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_lifecycle_configuration.app_managed_backup["cloudnative_pg"]
  id = "cloudnative-pg-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_lifecycle_configuration.app_managed_backup["longhorn"]
  id = "longhorn-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_lifecycle_configuration.app_managed_backup["seaweedfs"]
  id = "seaweedfs-default-backup"
}

import {
  to = module.seaweedfs_biscuit.aws_s3_bucket_lifecycle_configuration.app_managed_backup["velero"]
  id = "velero-backup"
}
```

### Workspace作成とimport

1. `infra` stateからSeaweedFS resourceを除去した後に`infra`workspaceのapplyを実行します。このapplyは3 workspace、Agent Pool、Agent token、credential、Variable Set、workspace variable、run triggerを作成し、下流2 workspaceのinitial runをqueueします。
2. `terraform-external-secrets` itemが更新され、biscuitのExternalSecretが新しいTerraform identityを読み込むことを確認します。credential変更時はbiscuitのS3 configが更新されてAgentが再起動されるため、endpointのReadyを確認してから下流runを進めます。
3. `seaweedfs-default`と`seaweedfs-biscuit`のAgent runがqueuedまたはplanningになることを確認します。endpoint未作成時はfailed runを増やすのではなく、Agentのinit containerが待機する状態を維持します。
4. 各initial runのplanでimportが実行され、bucket、policy、CORS、versioning、lifecycleにcreateやdestroyが残っていないことを確認します。`prevent_destroy`がある場合でも、planの差分が安全とはみなさず内容を確認します。
5. 成功したinitial runの後に一時`import.tf`を削除し、各workspaceの通常planで差分がないことを確認します。
6. `infra`側の1Password、B2、ZITADEL、Cloudflare、AWS IAMなどのresourceはstate移動しません。既存addressのまま`infra`workspaceで管理します。

### 中断と復旧

`state rm`前ならbackupしたstateを使わずに通常のplanへ戻せます。`state rm`後にimportできない場合は、下流workspaceのrunを停止して変更を広げず、import idとremote objectの存在を確認します。backup stateを復元する場合は、Terraform Cloudで対象state versionを明示して復元し、同じstateへ同時にapplyしないでください。

下流workspaceでimport済みのobjectを旧`module.seaweedfs[0]`へ戻すために、旧構成を再適用しないでください。管理addressを二重化するため、復旧方針を決めてからstate移動またはimportを行います。

## 静的検証

各Terraform rootでformat、backendを使わないinit、validateを実行します。Terraform Cloudへの接続やSeaweedFS endpointへのS3操作はこの静的検証には含まれません。

```bash
terraform fmt -check -recursive terraform
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform/workspaces/seaweedfs-default init -backend=false
terraform -chdir=terraform/workspaces/seaweedfs-biscuit init -backend=false
terraform -chdir=terraform/workspaces/seaweedfs-default validate
terraform -chdir=terraform/workspaces/seaweedfs-biscuit validate
```

`infra`rootの`cloud`設定はTerraform Cloud organizationの認証を要求するため、credentialがない環境では`init -backend=false`でも`unauthorized`で停止することがあります。その場合は認証を直してからrootを検証し、下流rootと独立moduleのvalidate成功だけでinfra rootの検証完了とはみなしません。

Argo CDのrenderでは`terraform-cloud-agent`のDeployment、ExternalSecret、HTTPS endpoint確認用init containerを含めてkubeconformで検証します。Agent Poolへの接続、Terraform Cloud run、ExternalSecret同期、SeaweedFS readiness、不要なdestroyがないことはlive確認として別途実施します。
