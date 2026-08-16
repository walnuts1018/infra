(import 'worker.libsonnet')('video-worker', 'ghcr.io/walnuts1018/picca/video-worker:v0.0.9')
+ {
  spec+: {
    template+: {
      spec+: {
        containers: [
          super.containers[0] {
            securityContext+: {
              readOnlyRootFilesystem: false,
            },
          },
        ],
      },
    },
  },
}
