local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: 'iwashi-smtp-relay',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'smtp_password',
      remoteRef: {
        key: 'resend',
        property: 'api-key',
      },
    },
  ],
}
