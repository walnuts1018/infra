std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: 'b2-secret',
  data: [
    {
      secretKey: 'application_key',
      remoteRef: {
        key: 'b2',
        property: 'application_key',
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
          AWS_ACCESS_KEY_ID: '004ab15b5942e2c0000000002',
          AWS_SECRET_ACCESS_KEY: '{{ .application_key }}',
          AWS_ENDPOINTS: 'https://s3.us-west-004.backblazeb2.com',
        },
      },
    },
  },
})
