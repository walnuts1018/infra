std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-minio',
  use_suffix: false,
  data: [
    {
      secretKey: 'redispassword',
      remoteRef: {
        key: 'redis',
        property: 'password',
      },
    },
    {
      secretKey: 'dbpassword',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'affine',
      },
    },
    {
      secretKey: 'mailerpassword',
      remoteRef: {
        key: 'resend',
        property: 'api-key',
      },
    },
    {
      secretKey: 'oidcclientsecret',
      remoteRef: {
        key: 'zitadel',
        property: 'affine',
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
          'postgres-url': 'postgres://affine:{{ .dbpassword }}@postgresql-default-rw.databases.svc.cluster.local/affine',
          redispassword: '{{ .redispassword }}',
          'mailer-password': '{{ .mailerpassword }}',
          'oidc-client-secret': '{{ .oidcclientsecret }}',
        },
      },
    },
  },
})
