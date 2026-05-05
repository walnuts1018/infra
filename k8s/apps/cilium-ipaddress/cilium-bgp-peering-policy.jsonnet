{
  apiVersion: 'cilium.io/v2alpha1',
  kind: 'CiliumBGPPeeringPolicy',
  metadata: {
    name: 'ix2215',
  },
  spec: {
    nodeSelector: {
      matchLabels: {
        'kubernetes.io/os': 'linux',
      },
    },
    virtualRouters: [
      {
        localASN: 65011,
        exportPodCIDR: false,
        neighbors: [
          {
            peerAddress: '192.168.0.1/32',
            peerASN: 65001,
          },
        ],
        serviceSelector: {
          matchExpressions: [
            { key: 'somekey', operator: 'NotIn', values: ['never-match'] },
          ],
        },
      },
    ],
  },
}
