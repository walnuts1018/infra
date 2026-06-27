std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: 'postgres-superuser-password',
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'postgres',
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        engineVersion: 'v2',
        type: 'kubernetes.io/basic-auth',
        data: {
          username: 'postgres',
          password: '{{ .password }}',
        },
      },
    },
  },
})
