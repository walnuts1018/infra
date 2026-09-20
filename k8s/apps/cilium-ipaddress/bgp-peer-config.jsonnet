local advertisement = import 'bgp-advertisement.jsonnet';
local configs = import 'config/bgp.libsonnet';
local config = configs[std.extVar('cluster')];

if config.enabled then {
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPPeerConfig',
  metadata: {
    name: config.peerConfigName,
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
  } + if std.objectHas(config, 'transport') then {
    transport: config.transport,
  } else {},
} else null
