// video-workerはffmpeg実行のためdebian-slimベースを使用しdistrolessではない。
// バイナリは静的リンクだが、apt管理のffmpeg/ca-certificatesが/usr以下に書き込まれているため
// 他ワーカーと違いreadOnlyRootFilesystemをfalseにする。
(import 'worker.libsonnet')('video-worker', 'ghcr.io/walnuts1018/picca/video-worker:latest')
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
