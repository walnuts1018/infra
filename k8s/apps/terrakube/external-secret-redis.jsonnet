(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-redis',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'redispassword',
      remoteRef: {
        key: 'terrakube',
        property: 'redis_password',
      },
    },
  ],
}
