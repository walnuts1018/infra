local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: 'github-app-secret',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'github_app_id',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'github_app_id',
      },
    },
    {
      secretKey: 'github_app_installation_id',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'github_app_installation_id',
      },
    },
    {
      secretKey: 'github_app_private_key',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'github_app_private_key',
      },
    },
  ],
  template_data: {
    github_app_id: '{{ .github_app_id }}',
    github_app_installation_id: '{{ .github_app_installation_id }}',
    github_app_private_key: '{{ .github_app_private_key }}',
  },
}
