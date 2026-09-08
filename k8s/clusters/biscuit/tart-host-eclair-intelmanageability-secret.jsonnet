(import '../../components/external-secret.libsonnet') {
  name: 'eclair-intelmanageability-credential',
  namespace: 'cluster-api-provider-tart-system',
  use_suffix: false,
  data: [
    {
      secretKey: 'username',
      remoteRef: {
        key: 'MEBx',
        property: 'username',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'MEBx',
        property: 'password',
      },
    },
  ],
}
