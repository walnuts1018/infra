(import '../../../components/external-secret.libsonnet') {
  name: (import '../app.json5').name + '-manifest-credentials',
  namespace: (import '../app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'minio_biscuit_secret_key',
      remoteRef: {
        key: 'longhorn',
        property: 'minio_secret_key',
      },
    },
    {
      secretKey: 'velero_accessKey',
      remoteRef: {
        key: 'velero',
        property: 'access_key',
      },
    },
    {
      secretKey: 'velero_secretKey',
      remoteRef: {
        key: 'velero',
        property: 'secret_key',
      },
    },
  ],
  template_data: {
    'longhorn-secret.yaml': (importstr './_manifests/longhorn-secret.yaml.tmpl'),
    'velero-secret.yaml': (importstr './_manifests/velero-secret.yaml.tmpl'),
  },
}
