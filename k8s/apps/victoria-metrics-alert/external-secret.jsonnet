local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  use_suffix: false,
  data: [
    { secretKey: 'discovery_key', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-discovery-key' } },
    { secretKey: 'smtp_password', remoteRef: { key: 'resend', property: 'api-key' } },
  ],
  template_data: {
    DISCOVERY_KEY: '{{ .discovery_key }}',
    SMTP_PASSWORD: '{{ .smtp_password }}',
  },
}
