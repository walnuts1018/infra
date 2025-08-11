(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'redispassword',
      remoteRef: {
        key: 'redis/password',
      },
    },
  ],
}
