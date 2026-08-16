(import 'worker.libsonnet')('thumbnail-worker', 'ghcr.io/walnuts1018/picca/thumbnail-worker:v0.0.10')
+ {
  spec+: {
    template+: {
      spec+: {
        containers: [
          super.containers[0] {
            resources+: {
              requests: { cpu: '20m', memory: '128Mi' },
              limits: { cpu: '2', memory: '4Gi' },
            },
          },
        ],
      },
    },
  },
}
