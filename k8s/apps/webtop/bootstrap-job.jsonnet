local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local bootstrapConfig = import 'bootstrap-configmap.jsonnet';
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
            image: 'lscr.io/linuxserver/webtop:arch-kde@sha256:d55dd7f34fe70e9e39fb004e3f7ef5eb0fd74b24a771ba972a25a24ce24f65a6',
            imagePullPolicy: 'IfNotPresent',
            command: ['/usr/bin/bash', '/scripts/bootstrap.sh'],
            env: [
              {
                name: 'ROOTFS_IMAGE_REFERENCE',
                value: 'lscr.io/linuxserver/webtop:arch-kde@sha256:d55dd7f34fe70e9e39fb004e3f7ef5eb0fd74b24a771ba972a25a24ce24f65a6',
              },
            ],
            securityContext: {
              runAsUser: 0,
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
                add: [
                  'CHOWN',
                  'DAC_OVERRIDE',
                  'FOWNER',
                  'SETFCAP',
                  'FSETID',
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
            ],
          },
        ],
        volumes: [
          {
            name: 'rootfs-source',
            image: {
              reference: 'lscr.io/linuxserver/webtop:arch-kde@sha256:d55dd7f34fe70e9e39fb004e3f7ef5eb0fd74b24a771ba972a25a24ce24f65a6',
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
        ],
      },
    },
  },
}
