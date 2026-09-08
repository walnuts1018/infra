{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
    namespace: (import 'cluster.json5').namespace,
  },
  spec: {
    template: {
      spec: {
        // hostSelector(label match)ではRetained/Reusable状態のHostを自動claimできないため、
        // 単一Host専用のこのクラスタではhostRefで直接指定する。
        hostRef: {
          name: 'eclair',
        },
        image: {
          version: (import 'cluster.json5').talosVersion,
          schematicID: '376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba',
        },
      },
    },
  },
}
