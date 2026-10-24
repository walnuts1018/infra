local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'zitadel-login-session-cookie',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'ZITADEL_SESSION_COOKIE_SECRET',
      remoteRef: {
        key: 'zitadel-login-session-cookie',
        property: 'ZITADEL_SESSION_COOKIE_SECRET',
      },
    },
  ],
}
