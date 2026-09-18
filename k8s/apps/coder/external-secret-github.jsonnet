local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'coder-github',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'coder',
        property: 'github-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'coder',
        property: 'github-client-secret',
      },
    },
  ],
}
