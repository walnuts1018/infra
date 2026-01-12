(import '../../components/external-secret.libsonnet') {
  name: 'tempo-credentials',
  use_suffix: false,
  data: [
    {
      secretKey: 'SEAWEED_ACCESS_KEY',
      remoteRef: {
        key: 'tempo',
        property: 'seaweed_access_key',
      },
    },
    {
      secretKey: 'SEAWEED_SECRET_KEY',
      remoteRef: {
        key: 'tempo',
        property: 'seaweed_secret_key',
      },
    },
  ],
}
