local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-runner',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'registration_token',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-runner-registration-token',
      },
    },
  ],
  template_data: {
    'registration-token': '{{ .registration_token }}',
    'runner-url': 'http://peertube.peertube.svc.cluster.local:9000',
  },
}
