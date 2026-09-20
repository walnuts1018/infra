local externalSecret = import '../../components/external-secret.libsonnet';
local flatten = import '../../components/flatten-resources.libsonnet';
local tartHost = import '../_components/tart-host.libsonnet';

local eclairCredentialName = 'eclair-intelmanageability-credential';

flatten({
  eclair: tartHost(
    'eclair',
    '18:03:73:e4:b9:e7',
    '192.168.0.15',
    { 'infrastructure.cluster.x-k8s.io/host-name': 'eclair' },
    {
      backend: 'IntelManageability',
      intelManageability: {
        address: 'http://192.168.0.15:16992/wsman',
        credentialSecretRef: { name: eclairCredentialName },
      },
    },
  ),
  eclairCredential: externalSecret {
    name: eclairCredentialName,
    namespace: 'tart-infrastructure-system',
    use_suffix: false,
    data: [
      { secretKey: 'username', remoteRef: { key: 'MEBx', property: 'username' } },
      { secretKey: 'password', remoteRef: { key: 'MEBx', property: 'password' } },
    ],
  },
})
