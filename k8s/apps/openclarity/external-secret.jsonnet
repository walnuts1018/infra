(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'openclarity',
      },
    },
  ],
}


std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'dbpassword',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'openclarity',
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
          username: 'openclarity',
          password: '{{ .dbpassword }}',
          database: 'openclarity',
        },
      },
    },
  },
})
