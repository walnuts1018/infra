{
  apiVersion: 'cilium.io/v2alpha1',
  kind: 'CiliumLoadBalancerIPPool',
  metadata: {
    name: 'default',
  },
  spec: {
    blocks: [
      {
        start: '192.168.0.128',
        stop: '192.168.0.156',
      },
    ],
  },
}