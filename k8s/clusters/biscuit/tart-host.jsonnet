{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartHost',
  metadata: {
    name: 'eclair',
    labels: {
      'infrastructure.cluster.x-k8s.io/host-name': 'eclair',
    },
  },
  spec: {
    macAddress: '18:03:73:e4:b9:e7',
    talosAPIAddress: '192.168.0.15',
    architecture: 'amd64',
    power: {
      backend: 'IntelManageability',
      intelManageability: {
        address: 'http://192.168.0.15:16992/wsman',
        credentialSecretRef: {
          name: (import 'tart-host-eclair-intelmanageability-secret.jsonnet').spec.target.name,
        },
      },
    },
  },
}
