local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: app.name,
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'TFC_AGENT_TOKEN',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'terraform_cloud_agent_token',
      },
    },
  ],
}
