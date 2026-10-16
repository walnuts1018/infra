(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-db-reset-password',
  data: [{
    secretKey: 'password',
    remoteRef: {
      key: 'terraform-external-secrets',
      property: 'horse-database-password',
    },
  }],
  template_data: {
    password: '{{ .password }}',
  },
  metadata+: {
    annotations: { 'argocd.argoproj.io/sync-wave': '-2' },
  },
}
