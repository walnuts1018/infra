std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-db-password',
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'misskey',
        property: 'dbpassword',
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
          username: 'misskey',
          password: '{{ .password }}',
        },
      },
    },
  },
})
