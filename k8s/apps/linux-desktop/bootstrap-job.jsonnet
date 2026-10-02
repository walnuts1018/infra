local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local bootstrapConfig = import 'bootstrap-configmap.jsonnet';
local images = import 'images.libsonnet';
local jobName = app.name + '-bootstrap';
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: jobName + '-' + std.md5(std.toString($.spec) + std.toString(bootstrapConfig))[0:10],
    namespace: app.namespace,
    labels: labels(jobName),
    annotations: {
      'argocd.argoproj.io/sync-wave': '-1',
    },
  },
  spec: {
    activeDeadlineSeconds: 7200,
    backoffLimit: 0,
    template: {
      metadata: {
        labels: labels(jobName),
      },
      spec: {
        automountServiceAccountToken: false,
        restartPolicy: 'Never',
        terminationGracePeriodSeconds: 30,
        securityContext: {
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'bootstrap',
            image: images.archlinux,
            imagePullPolicy: 'IfNotPresent',
            command: ['/usr/bin/bash', '/scripts/bootstrap.sh'],
            env: [
              {
                name: 'ROOTFS_IMAGE_REFERENCE',
                value: images.archlinux,
              },
            ],
            securityContext: {
              runAsUser: 0,
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
                add: [
                  'SYS_ADMIN',
                  'SYS_CHROOT',
                  'CHOWN',
                  'DAC_OVERRIDE',
                  'FOWNER',
                  'SETUID',
                  'SETGID',
                  'SETFCAP',
                ],
              },
            },
            resources: {
              requests: {
                cpu: '500m',
                memory: '1Gi',
              },
              limits: {
                cpu: '2',
                memory: '4Gi',
              },
            },
            volumeMounts: [
              { name: 'rootfs-source', mountPath: '/source', readOnly: true },
              { name: 'rootfs-target', mountPath: '/target' },
              { name: 'bootstrap-scripts', mountPath: '/scripts', readOnly: true },
              { name: 'run', mountPath: '/run' },
              { name: 'tmp', mountPath: '/tmp' },
              { name: 'dev-shm', mountPath: '/dev/shm' },
            ],
          },
        ],
        volumes: [
          {
            name: 'rootfs-source',
            image: {
              reference: images.archlinux,
              pullPolicy: 'IfNotPresent',
            },
          },
          {
            name: 'rootfs-target',
            persistentVolumeClaim: {
              claimName: app.name + '-root',
            },
          },
          {
            name: 'bootstrap-scripts',
            configMap: {
              name: bootstrapConfig.metadata.name,
              defaultMode: 292,
            },
          },
          {
            name: 'run',
            emptyDir: {
              medium: 'Memory',
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'dev-shm',
            emptyDir: {
              medium: 'Memory',
              sizeLimit: '1Gi',
            },
          },
        ],
      },
    },
  },
}
