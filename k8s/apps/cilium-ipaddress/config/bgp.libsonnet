{
  kurumi: {
    enabled: true,
    instanceName: 'talos',
    peerConfigName: 'talos',
    nodeSelector: {
      matchLabels: {
        'node-role.kubernetes.io/control-plane': '',
      },
    },
    localASN: 4200000003,
    peerASN: 4200000002,
    peerAddress: '10.255.255.1',
    transport: {
      peerPort: 179,
      sourceInterface: 'veth-cilium',
      timers: {
        connectRetryTimeSeconds: 3,
        holdTimeSeconds: 9,
        keepAliveTimeSeconds: 3,
      },
    },
  },
  biscuit: {
    enabled: true,
    instanceName: 'server-vlan',
    peerConfigName: 'vanilla',
    nodeSelector: {
      matchLabels: {
        'kubernetes.io/os': 'linux',
      },
    },
    localASN: 65010,
    localPort: 1790,
    peerASN: 65001,
    peerAddress: '192.168.0.1',
  },
}
