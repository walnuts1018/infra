local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'radar-auth',
  use_suffix: false,
  data: [
    {
      secretKey: 'auth-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'radar-auth-secret',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'radar-client-secret',
      },
    },
  ],
}
