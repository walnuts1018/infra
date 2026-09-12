local externalSecret = import '../../components/external-secret.libsonnet';
local flatten = import '../../components/flatten-resources.libsonnet';
local tartHost = import '../_components/tart-host.libsonnet';

// cake/hotate/lemonにはBMC/AMTがなく、電源投入はWake-on-LANのみ可能(電源状態の観測はできない)。
local wol = { backend: 'WakeOnLAN', wakeOnLAN: { broadcastAddress: '192.168.0.255:9' } };
local controlPlanePool = { 'kurumi.walnuts.dev/pool': 'control-plane' };

local ruskRedfishSecretName = 'rusk-redfish-credential';

flatten({
  cake: tartHost(
    'cake',
    'a8:a1:59:ac:dd:2b',
    '192.168.0.25',
    { 'infrastructure.cluster.x-k8s.io/host-name': 'cake' } + controlPlanePool,
    wol,
  ),
  hotate: tartHost(
    'hotate',
    '7c:83:34:be:e6:9b',
    '192.168.0.26',
    { 'infrastructure.cluster.x-k8s.io/host-name': 'hotate' } + controlPlanePool,
    wol,
  ),
  // lemonの現行UEFI boot orderにはネットワークブートのエントリがないため、初回enrollment前に
  // BIOSでPXE/ネットワークブートを有効化しboot orderへ追加しておく必要がある(物理作業)。
  lemon: tartHost(
    'lemon',
    '4c:85:8a:eb:89:73',
    '192.168.0.19',
    { 'infrastructure.cluster.x-k8s.io/host-name': 'lemon' } + controlPlanePool,
    wol,
  ),
  rusk: tartHost(
    'rusk',
    '28:80:23:b6:fa:e8',
    '192.168.0.101',
    { 'infrastructure.cluster.x-k8s.io/host-name': 'rusk', 'kurumi.walnuts.dev/pool': 'worker' },
    {
      backend: 'Redfish',
      redfish: {
        // rusk(HP ProLiant DL120 Gen9)のiLO。ipmitool lan printで確認済み(management VLAN、DHCP)。
        address: 'https://192.168.4.101',
        credentialSecretRef: { name: ruskRedfishSecretName },
      },
    },
  ),
  ruskRedfishCredential: externalSecret {
    name: ruskRedfishSecretName,
    namespace: 'tart-infrastructure-system',
    use_suffix: false,
    data: [
      { secretKey: 'username', remoteRef: { key: 'rusk iLO', property: 'username' } },
      { secretKey: 'password', remoteRef: { key: 'rusk iLO', property: 'password' } },
    ],
  },
})
