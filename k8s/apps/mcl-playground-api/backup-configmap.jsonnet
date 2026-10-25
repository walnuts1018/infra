local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-backup-rclone-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-backup'),
  data: {
    'rclone.conf': |||
      [seaweed]
      type = s3
      provider = Other
      env_auth = true
      endpoint = http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333
      region = us-east-1
      no_check_bucket = true

      [b2]
      type = b2
    |||,
  },
}
