function(cidr) {
  apiVersion: 'cilium.io/v2alpha1',
  kind: 'CiliumLoadBalancerIPPool',
  metadata: {
    name: 'default',
  },
  spec: {
    blocks: [
      {
        cidr: cidr,
      },
    ],
  },
}
