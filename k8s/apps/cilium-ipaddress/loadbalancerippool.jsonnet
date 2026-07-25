function(start='192.168.12.0', stop='192.168.12.255') {
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumLoadBalancerIPPool',
  metadata: {
    name: 'default',
  },
  spec: {
    blocks: [
      {
        start: start,
        stop: stop,
      },
    ],
  },
}
