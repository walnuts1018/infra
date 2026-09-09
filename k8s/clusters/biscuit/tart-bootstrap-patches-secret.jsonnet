{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane-patches',
    namespace: (import 'cluster.json5').namespace,
  },
  type: 'Opaque',
  stringData: {
    patches: |||
      apiVersion: v1alpha1
      kind: UnattendedInstallConfig
      provisioning:
        diskSelector:
          match: '!disk.readonly && disk.size == 240057409536u && disk.wwid == "t10.ATA     ADATA SU650                             38F8079715D100008282"'
        wipe: false
      ---
      # OSディスク上の未使用領域を、SeaweedFSメタデータ用のLVM PVとして確保する。
      # system_disk全体ではなくRawVolumeConfigが作る専用パーティションだけをLVMへ渡す。
      apiVersion: v1alpha1
      kind: VolumeConfig
      name: EPHEMERAL
      provisioning:
        maxSize: 160GiB
      ---
      apiVersion: v1alpha1
      kind: RawVolumeConfig
      name: topolvm-ssd
      provisioning:
        diskSelector:
          match: 'system_disk && !disk.readonly && disk.size == 240057409536u && disk.wwid == "t10.ATA     ADATA SU650                             38F8079715D100008282"'
        minSize: 20GiB
        maxSize: 40GiB
        grow: false
      ---
      apiVersion: v1alpha1
      kind: LVMVolumeGroupConfig
      name: ssd
      provisioning:
        volumeSelector:
          match: "volume.partition_label == 'r-topolvm-ssd'"
      ---
      apiVersion: v1alpha1
      kind: LVMVolumeGroupConfig
      name: hdd
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
      # nodeがネットワーク予約名(例: server-reserved-15)で登録されてしまう。providerがCAPI
      # Machine名で静的hostnameを生成した上でこのpatchを適用するため、ここではhostnameを
      # TartHost名で上書きするだけでよい(autoフィールドはprovider側で既に取り除かれている)。
      apiVersion: v1alpha1
      kind: HostnameConfig
      hostname: eclair
      ---
      # SeaweedFS/バックアップ転送時の瞬間的なメモリ圧迫でkube-apiserver等がOOMKillされるのを
      # 避けるための安全弁。常用メモリをswapへ逃がす前提ではなく、あくまで緊急退避用。
      apiVersion: v1alpha1
      kind: KubeletConfig
      config:
        memorySwap:
          swapBehavior: LimitedSwap
      ---
      # 単一node(control plane兼worker)構成のため、通常のPodをcontrol planeへscheduleできる
      # ようにNoSchedule taintを取り除く。Talosの`$patch: delete`構文でfieldごと削除する。
      apiVersion: v1alpha1
      kind: KubeNodeConfig
      taints:
        $patch: delete
    |||,
  },
}
