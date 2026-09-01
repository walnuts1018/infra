local app = import 'app.json5';

local config = |||
  [seaweedmaps]
  type = s3
  provider = Other
  env_auth = true
  endpoint = http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333
  region = us-east-1
  no_check_bucket = true
|||;

(import '../../components/configmap.libsonnet') {
  name: app.name + '-rclone-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-update'),
  data: {
    'rclone.conf': config,
  },
}
