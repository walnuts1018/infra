local advertisement = import 'bgp-advertisement.jsonnet';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPPeerConfig',
  metadata: {
    name: 'vanilla',
  },
  spec: {
    families: [
      {
        afi: 'ipv4',
        safi: 'unicast',
        advertisements: {
          matchLabels: advertisement.metadata.labels,
        },
      },
    ],
  },
}
