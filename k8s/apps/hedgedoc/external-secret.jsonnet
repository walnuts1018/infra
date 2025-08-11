std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'dbpassword',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'hedgedoc',
      },
    },
    {
      secretKey: 'clientsecret',
      remoteRef: {
        key: 'hedgedoc',
        property: 'client-secret',
      },
    },
    {
      secretKey: 'minioaccesskey',
      remoteRef: {
        key: 'hedgedoc',
        property: 'minio-access-key',
      },
    },
    {
      secretKey: 'miniosecretkey',
      remoteRef: {
        key: 'hedgedoc',
        property: 'minio-secret-key',
      },
    },
    {
      secretKey: 'sessionsecret',
      remoteRef: {
        key: 'hedgedoc',
        property: 'session-secret',
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
          'db-url': 'postgres://hedgedoc:{{ .dbpassword }}@postgresql-default-rw.databases.svc.cluster.local/hedgedoc',
          'client-secret': '{{ .clientsecret }}',
          'minio-access-key': '{{ .minioaccesskey }}',
          'minio-secret-key': '{{ .miniosecretkey }}',
          'session-secret': '{{ .sessionsecret }}',
        },
      },
    },
  },
})
