local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local images = import 'images.libsonnet';
local launcherConfig = import 'launcher-configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    strategy: {
      type: 'Recreate',
    },
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        automountServiceAccountToken: false,
        terminationGracePeriodSeconds: 30,
        securityContext: {
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'desktop',
            image: images.archlinux,
            imagePullPolicy: 'IfNotPresent',
            command: ['/usr/bin/bash', '/launcher/runtime-launcher.sh'],
            securityContext: {
              runAsUser: 0,
              allowPrivilegeEscalation: true,
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
            startupProbe: {
              exec: {
                command: [
                  '/usr/bin/bash',
                  '-ec',
                  'echo >/dev/tcp/127.0.0.1/5900',
                ],
              },
              periodSeconds: 10,
              timeoutSeconds: 2,
              failureThreshold: 60,
            },
            readinessProbe: {
              exec: {
                command: [
                  '/usr/bin/bash',
                  '-ec',
                  'echo >/dev/tcp/127.0.0.1/5900',
                ],
              },
              periodSeconds: 10,
              timeoutSeconds: 2,
              failureThreshold: 3,
            },
            resources: {
              requests: {
                cpu: '500m',
                memory: '2Gi',
              },
              limits: {
                cpu: '4',
                memory: '8Gi',
              },
            },
            volumeMounts: [
              { name: 'rootfs', mountPath: '/sysroot' },
              { name: 'launcher', mountPath: '/launcher', readOnly: true },
              { name: 'run', mountPath: '/run' },
              { name: 'tmp', mountPath: '/tmp' },
              { name: 'dev-shm', mountPath: '/dev/shm' },
            ],
          },
          {
            name: 'novnc',
            image: images.novnc,
            imagePullPolicy: 'IfNotPresent',
            env: [
              { name: 'VNCADDR', value: '127.0.0.1:5900' },
            ],
            ports: [
              { name: 'http', containerPort: 8080, protocol: 'TCP' },
            ],
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
            startupProbe: {
              httpGet: {
                path: '/vnc.html',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 3,
              failureThreshold: 30,
            },
            readinessProbe: {
              httpGet: {
                path: '/vnc.html',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 3,
              failureThreshold: 3,
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '32Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          {
            name: 'rootfs',
            persistentVolumeClaim: {
              claimName: app.name + '-root',
            },
          },
          {
            name: 'launcher',
            configMap: {
              name: launcherConfig.metadata.name,
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
