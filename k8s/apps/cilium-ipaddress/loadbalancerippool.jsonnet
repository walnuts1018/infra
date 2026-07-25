function(start='192.168.0.128', stop='192.168.0.155') {
  apiVersion: 'cilium.io/v2alpha1',
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
