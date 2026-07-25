local peerConfig = import 'bgp-peer-config.jsonnet';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPClusterConfig',
  metadata: {
    name: 'server-vlan',
  },
  spec: {
    nodeSelector: {
      matchLabels: {
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
