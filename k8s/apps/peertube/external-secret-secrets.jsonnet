local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-secrets',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'admin_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-root-password',
      },
    },
    {
      secretKey: 'peertube_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-secret',
      },
    },
  ],
  template_data: {
    'admin-password': '{{ .admin_password }}',
    'peertube-secret': '{{ .peertube_secret }}',
  },
}
