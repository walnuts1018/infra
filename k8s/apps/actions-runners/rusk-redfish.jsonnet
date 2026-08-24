local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: 'rusk-redfish',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'username',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'redfish_username',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'redfish_password',
      },
    },
  ],
  template_data: {
    username: '{{ .username }}',
    password: '{{ .password }}',
  },
}
