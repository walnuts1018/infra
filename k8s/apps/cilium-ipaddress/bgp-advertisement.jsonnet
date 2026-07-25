{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPAdvertisement',
  metadata: {
    name: 'load-balancer-ips',
    labels: {
      'bgp.cilium.io/advertise': 'load-balancer-ips',
    },
  },
  spec: {
    advertisements: [
      {
        advertisementType: 'Service',
        service: {
          addresses: [
            'LoadBalancerIP',
          ],
        },
        selector: {
          matchExpressions: [
            {
              key: 'somekey',
              operator: 'NotIn',
              values: ['never-used-value'],
            },
          ],
        },
      },
    ],
  },
}
