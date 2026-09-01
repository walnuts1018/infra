// presigned URL発行専用の読み取り専用identity(maps_read)のcredentialだけをここで扱う。
// mapsバケットへの書き込み(rclone-sync)はWebIdentity AssumeRole(s3-irsa.libsonnet)を
// 使うため、静的credentialは不要。
(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'maps_read_secretkey',
      },
    },
  ],
  template_data: {
    RCLONE_CONFIG_SEAWEEDMAPSREAD_ACCESS_KEY_ID: 'maps_read',
    RCLONE_CONFIG_SEAWEEDMAPSREAD_SECRET_ACCESS_KEY: '{{ .secretkey }}',
  },
}
