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
        volumeSelector:
          match: '!disk.readonly && disk.size == 1000204886016u && disk.wwid == "naa.50014ee2118ad24b"'
      ---
      apiVersion: v1alpha1
      kind: SwapVolumeConfig
      name: swap
      provisioning:
        diskSelector:
          match: '!disk.readonly && disk.size == 240057409536u && disk.wwid == "t10.ATA     ADATA SU650                             38F8079715D100008282"'
        maxSize: 4GiB
      ---
      # DHCP(vyos側のstatic reservation名)がTalosの自動生成hostnameより優先されてしまい、
      # nodeがネットワーク予約名(例: server-reserved-15)で登録されてしまう。
      # DHCP由来の名前を上書きするため、TartHost名と一致する静的hostnameを明示する。
      apiVersion: v1alpha1
      kind: HostnameConfig
      hostname: eclair
      ---
      # kube-proxyはCiliumのkube-proxy replacementで代替するため無効化する。
      apiVersion: v1alpha1
      kind: KubeProxyConfig
      enabled: false
      ---
      # SeaweedFS/バックアップ転送時の瞬間的なメモリ圧迫でkube-apiserver等がOOMKillされるのを
      # 避けるための安全弁。常用メモリをswapへ逃がす前提ではなく、あくまで緊急退避用。
      apiVersion: v1alpha1
      kind: KubeletConfig
      config:
        memorySwap:
          swapBehavior: LimitedSwap
    |||,
  },
}
