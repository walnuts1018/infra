(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'maps_rclone_secretkey',
      },
    },
  ],
  template_data: {
    RCLONE_CONFIG_SEAWEEDMAPS_TYPE: 's3',
    RCLONE_CONFIG_SEAWEEDMAPS_PROVIDER: 'Other',
    RCLONE_CONFIG_SEAWEEDMAPS_ENV_AUTH: 'false',
    RCLONE_CONFIG_SEAWEEDMAPS_ENDPOINT: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
    RCLONE_CONFIG_SEAWEEDMAPS_NO_CHECK_BUCKET: 'true',
    RCLONE_CONFIG_SEAWEEDMAPS_ACCESS_KEY_ID: 'maps_rclone',
    RCLONE_CONFIG_SEAWEEDMAPS_SECRET_ACCESS_KEY: '{{ .secretkey }}',
  },
}
