// kurumiの各ノードでTalosのLVMVolumeGroupConfigが作るVG"data"の上に、
// LonghornとTopoLVMが共有するthin-pool("pool0")とLonghorn用のthin LV("lv-longhorn")を用意する。
// Talosの宣言的config(LVMVolumeGroupConfig/LVMLogicalVolumeConfig)はVGとlinear/raid LVの作成にしか
// 対応しておらずthin-poolを直接作れないため、この一回限りの初期化だけは特権DaemonSetで冪等に行う。
// mountはmountPropagation: Bidirectionalで/var/lib/longhornへ伝播させ、ホスト側から見えるようにする。
local initScript = importstr '_scripts/init.sh';
{
  apiVersion: 'apps/v1',
  kind: 'DaemonSet',
  metadata: {
    name: 'lvm-thinpool-init',
    namespace: 'lvm-thinpool-init',
  },
  spec: {
    selector: {
      matchLabels: { app: 'lvm-thinpool-init' },
    },
    template: {
      metadata: {
        labels: { app: 'lvm-thinpool-init' },
      },
      spec: {
        hostPID: true,
        nodeSelector: {
          'kubernetes.io/os': 'linux',
        },
        tolerations: [
          { operator: 'Exists' },
        ],
        containers: [
          {
            name: 'init',
            image: 'alpine:3.20',
            securityContext: {
              privileged: true,
            },
            env: [
              { name: 'LONGHORN_LV_SIZE_GIB', value: '200' },
            ],
            command: ['/bin/sh', '-c', initScript],
            volumeMounts: [
              { name: 'dev', mountPath: '/dev' },
              { name: 'run-lvm', mountPath: '/run/lvm' },
              {
                name: 'longhorn',
                mountPath: '/mnt/longhorn',
                mountPropagation: 'Bidirectional',
              },
            ],
            livenessProbe: {
              exec: { command: ['mountpoint', '-q', '/mnt/longhorn'] },
              initialDelaySeconds: 60,
              periodSeconds: 30,
            },
          },
        ],
        volumes: [
          { name: 'dev', hostPath: { path: '/dev' } },
          { name: 'run-lvm', hostPath: { path: '/run/lvm', type: 'DirectoryOrCreate' } },
          { name: 'longhorn', hostPath: { path: '/var/lib/longhorn', type: 'DirectoryOrCreate' } },
        ],
      },
    },
  },
}
