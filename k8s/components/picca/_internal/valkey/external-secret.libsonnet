function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-valkey',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'valkey_password',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-redis-password',
        },
      },
    ],
    template_data: {
      VALKEY_URL: 'redis://:{{ .valkey_password }}@valkey-' + app.name + '-valkey.' + app.namespace + '.svc.cluster.local:6379/0',
      valkey_password: '{{ .valkey_password }}',
    },
  }
