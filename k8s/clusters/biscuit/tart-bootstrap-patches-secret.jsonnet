{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane-patches',
    namespace: (import 'cluster.json5').namespace,
  },
  type: 'Opaque',
  immutable: false,
  stringData: {
    patches: |||
      cluster:
        network:
          cni:
            name: none # Ciliumを使う
        proxy:
          disabled: true
        allowSchedulingOnControlPlanes: true
      ---
      apiVersion: v1alpha1
      kind: UnattendedInstallConfig
      provisioning:
        diskSelector:
          match: '!disk.readonly && disk.size == 240057409536u && disk.wwid == "t10.ATA     ADATA SU650                             38F8079715D100008282"'
        wipe: false
      ---
      apiVersion: v1alpha1
      kind: LVMVolumeGroupConfig
      name: topolvm
      provisioning:
        diskSelector:
          match: '!disk.readonly && disk.size == 1000204886016u && disk.wwid == "naa.50014ee2118ad24b"'
        wipe: false
      ---
      apiVersion: v1alpha1
      kind: SwapVolumeConfig
      name: swap
      provisioning:
        diskSelector:
          match: '!disk.readonly && disk.size == 240057409536u && disk.wwid == "t10.ATA     ADATA SU650                             38F8079715D100008282"'
        maxSize: 4GiB
      ---
      machine:
        kubelet:
          extraConfig:
            memorySwap:
              swapBehavior: LimitedSwap
    |||,
  },
}
