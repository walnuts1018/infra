std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-minio',
  use_suffix: false,
  data: [
    {
      secretKey: 'redispassword',
      remoteRef: {
        key: 'redis/password',
      },
    },
    {
      secretKey: 'dbpassword',
      remoteRef: {
        key: 'postgres_passwords/affine',
      },
    },
    {
      secretKey: 'mailerpassword',
      remoteRef: {
        key: 'resend/api-key',
      },
    },
    {
      secretKey: 'oidcclientsecret',
      remoteRef: {
        key: 'zitadel/affine',
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
          'postgres-url': 'postgres://affine:{{ .dbpassword }}@postgresql-default.databases.svc.cluster.local/affine',
          redispassword: '{{ .redispassword }}',
          'mailer-password': '{{ .mailerpassword }}',
          'oidc-client-secret': '{{ .oidcclientsecret }}',
        },
      },
    },
  },
})
