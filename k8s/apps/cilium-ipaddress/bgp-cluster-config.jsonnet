local peerConfig = import 'bgp-peer-config.jsonnet';
local configs = import 'config/bgp.libsonnet';
local config = configs[std.extVar('cluster')];
local instance = {
  name: config.instanceName,
  localASN: config.localASN,
  peers: [
    {
      name: peerConfig.metadata.name,
      peerASN: config.peerASN,
      peerAddress: config.peerAddress,
      peerConfigRef: {
        name: peerConfig.metadata.name,
      },
    },
  ],
} + if std.objectHas(config, 'localPort') then {
  localPort: config.localPort,
} else {};

if config.enabled then {
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumBGPClusterConfig',
  metadata: {
    name: config.instanceName,
  },
  spec: {
    nodeSelector: config.nodeSelector,
    bgpInstances: [instance],
  },
} else null
