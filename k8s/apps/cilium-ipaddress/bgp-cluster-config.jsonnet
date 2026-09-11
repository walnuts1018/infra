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
      matchLabels: if cluster == 'kurumi' then {
        // Talos advertises the API VIP from control-plane nodes. Keep the
        // Cilium service-BGP speaker on workers to avoid two speakers using
        // the same node address and ASN on the same VyOS neighbor.
        'kurumi.walnuts.dev/pool': 'worker',
      } else {
        'kubernetes.io/os': 'linux',
      },
    },
    bgpInstances: [
      {
        name: 'server-vlan',
        localASN: 65010,
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
