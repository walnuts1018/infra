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
    // 直前のTartMachine(biscuit-0)はTalosのinstallが完了する前に削除されたため、
    // 保持されたHost stateをReprovision(明示的にclaimしてidentityを再確認し、
    // data破棄はTalos resetとinstaller lifecycleへ委譲)で再利用する。
    reusePolicy: 'AllowReuse',
    reuseMode: 'Reprovision',
    reuseApproval: {
      previousConsumerUID: '3b332cc4-8da8-4fa9-8f56-7e20d7bab8fa',
    },
  },
}
