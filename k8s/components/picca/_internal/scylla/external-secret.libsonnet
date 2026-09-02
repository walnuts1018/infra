function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-scylla',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'scylla_password',
        remoteRef: {
          key: 'scylladb',
          property: std.strReplace(app.name, '-', '_'),
        },
      },
    ],
    template_data: {
      SCYLLA_PASSWORD: '{{ .scylla_password }}',
    },
  }
