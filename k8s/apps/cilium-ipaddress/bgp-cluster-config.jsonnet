local peerConfig = import 'bgp-peer-config.jsonnet';
local cluster = std.extVar('cluster');

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPClusterConfig',
  metadata: {
    name: 'server-vlan',
  },
  spec: {
    nodeSelector: {
      // Talos listens on the standard BGP port 179. Cilium uses a separate
      // local port so it can run on control-plane nodes as well as workers.
      matchLabels: {
        'kubernetes.io/os': 'linux',
      },
    },
    bgpInstances: [
      {
        name: 'server-vlan',
        localASN: 65010,
        localPort: 1790,
        peers: [
          {
            name: peerConfig.metadata.name,
            peerASN: 65001,
            peerAddress: '192.168.0.1',
            peerConfigRef: {
              name: peerConfig.metadata.name,
            },
          },
        ],
      },
    ],
  },
}
