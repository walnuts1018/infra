{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane-patches',
    namespace: (import 'cluster.json5').namespace,
  },
  type: 'Opaque',
  immutable: true,
  stringData: {
    patches: |||
      cluster: {}
      ---
      apiVersion: v1alpha1
      kind: UnattendedInstallConfig
      provisioning:
        diskSelector:
          match: '!disk.rotational'
        wipe: false
      ---
      apiVersion: v1alpha1
      kind: LVMVolumeGroupConfig
      name: topolvm
      provisioning:
        diskSelector:
          match: 'disk.rotational'
        wipe: false
    |||,
  },
}
