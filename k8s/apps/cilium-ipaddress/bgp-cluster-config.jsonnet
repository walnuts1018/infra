local peerConfig = import 'bgp-peer-config.jsonnet';
local cluster = std.extVar('cluster');
local kurumi = cluster == 'kurumi';
local nodeSelectorLabels = if kurumi then {
  'node-role.kubernetes.io/control-plane': '',
} else {
  'kubernetes.io/os': 'linux',
};
local instance = {
  name: if kurumi then 'talos' else 'server-vlan',
  localASN: if kurumi then 4200000003 else 65010,
  peers: [
    {
      name: peerConfig.metadata.name,
      peerASN: if kurumi then 4200000002 else 65001,
      peerAddress: if kurumi then '10.255.255.1' else '192.168.0.1',
      peerConfigRef: {
        name: peerConfig.metadata.name,
      },
    },
  ],
} + if kurumi then {} else {
  localPort: 1790,
};

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPClusterConfig',
  metadata: {
    name: if kurumi then 'talos' else 'server-vlan',
  },
  spec: {
    nodeSelector: {
      matchLabels: nodeSelectorLabels,
    },
    // Kurumi uses an active Cilium-to-Talos veth session; biscuit keeps its
    // direct Cilium-to-upstream session.
    bgpInstances: [instance],
  },
}
