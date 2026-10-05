local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-discovery',
  namespace: app.namespace,
  data: [{
    secretKey: 'discovery_key',
    remoteRef: {
      key: 'terraform-external-secrets',
      property: 'iwashi-discovery-key',
    },
  }],
  template_data: {
    DISCOVERY_KEY: '{{ .discovery_key }}',
  },
}
