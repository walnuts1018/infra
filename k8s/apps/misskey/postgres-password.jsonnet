local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
std.mergePatch((externalSecret) {
  name: app.name + '-db-password',
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
