local app = import 'app.json5';

// seaweedmaps: upstream(HTTP)->mapsバケットへの書き込み用。SeaweedFS STS経由の
// WebIdentity AssumeRole(env_auth+sts_endpoint、s3-irsa.libsonnetがtoken/role ARNを注入)
// を使うため、access_key_id/secret_access_keyは一切書かない。
// seaweedmapsread: VersaTiles配信用presigned URLを発行するための読み取り専用remote。
// WebIdentityの一時クレデンシャルはセッション寿命が短く(desired-state.jsonのsts設定で
// 1〜12時間)、月1回しか更新しないpresigned URLの署名には使えないため、こちらだけは
// 長寿命のstatic access keyにする(secret_access_keyだけはSecretから環境変数
// RCLONE_CONFIG_SEAWEEDMAPSREAD_SECRET_ACCESS_KEYで注入、rcloneはconfig fileの値と
// 同名remoteのRCLONE_CONFIG_*環境変数をマージする)。
local config = |||
  [seaweedmaps]
  type = s3
  provider = Other
  env_auth = true
  endpoint = http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333
  sts_endpoint = http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333
  region = us-east-1
  no_check_bucket = true

  [seaweedmapsread]
  type = s3
  provider = Other
  env_auth = false
  access_key_id = maps_read
  endpoint = http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333
  region = us-east-1
|||;

(import '../../components/configmap.libsonnet') {
  name: app.name + '-rclone-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-update'),
  data: {
    'rclone.conf': config,
  },
}
