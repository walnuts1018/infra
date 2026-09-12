local advertisement = import 'bgp-advertisement.jsonnet';
local cluster = std.extVar('cluster');

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPPeerConfig',
  metadata: {
    name: if cluster == 'kurumi' then 'talos' else 'vanilla',
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
  } + if cluster == 'kurumi' then {
    transport: {
      peerPort: 179,
      sourceInterface: 'veth-cilium',
    },
    timers: {
      connectRetryTimeSeconds: 3,
      holdTimeSeconds: 9,
      keepAliveTimeSeconds: 3,
    },
  } else {},
}
