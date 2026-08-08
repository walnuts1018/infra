local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'orchestra-secrets-source',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'OIDC_CLIENT_ID',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'openunison-client-id',
      },
    },
    {
      secretKey: 'OIDC_CLIENT_SECRET',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'openunison-client-secret',
      },
    },
    {
      secretKey: 'unisonKeystorePassword',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'openunison-keystore-password',
      },
    },
  ],
  template_data: {
    OIDC_CLIENT_ID: '{{ .OIDC_CLIENT_ID }}',
    OIDC_CLIENT_SECRET: '{{ .OIDC_CLIENT_SECRET }}',
    unisonKeystorePassword: '{{ .unisonKeystorePassword }}',
  },
} + {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/sync-wave': '-1',
    },
  },
}
