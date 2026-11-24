local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-valkey-credential',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'valkey_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-redis-password',
      },
    },
  ],
  template_data: {
    AGR_VALKEY_URL: 'redis://:{{ .valkey_password }}@valkey-' + app.name + '-valkey.' + app.namespace + '.svc.cluster.local:6379/0',
  },
}
