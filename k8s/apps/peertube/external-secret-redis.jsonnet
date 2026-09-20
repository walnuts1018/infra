local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-redis',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'redis_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-redis-password',
      },
    },
  ],
  template_data: {
    'redis-password': '{{ .redis_password }}',
    valkey_password: '{{ .redis_password }}',
  },
}
