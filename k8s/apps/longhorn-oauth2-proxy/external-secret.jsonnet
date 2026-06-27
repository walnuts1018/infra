local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local app = (app);
(externalSecret) {
  name: app.name + '-secret',
  data: [
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'longhorn-oauth2-proxy',
        property: 'client_secret',
      },
    },
  ],
}
