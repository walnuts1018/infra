std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'dbpassword',
      remoteRef: {
        key: 'postgres_passwords/hedgedoc',
      },
    },
    {
      secretKey: 'clientsecret',
      remoteRef: {
        key: 'hedgedoc/client-secret',
      },
    },
    {
      secretKey: 'minioaccesskey',
      remoteRef: {
        key: 'hedgedoc/minio-access-key',
      },
    },
    {
      secretKey: 'miniosecretkey',
      remoteRef: {
        key: 'hedgedoc/minio-secret-key',
      },
    },
    {
      secretKey: 'sessionsecret',
      remoteRef: {
        key: 'hedgedoc/session-secret',
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
        data: {
          'db-url': 'postgres://hedgedoc:{{ .dbpassword }}@postgresql-default.databases.svc.cluster.local/hedgedoc',
          'client-secret': '{{ .clientsecret }}',
          'minio-access-key': '{{ .minioaccesskey }}',
          'minio-secret-key': '{{ .miniosecretkey }}',
          'session-secret': '{{ .sessionsecret }}',
        },
      },
    },
  },
})
