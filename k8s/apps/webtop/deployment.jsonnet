local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local launcherConfig = import 'launcher-configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
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
            name: 'webtop',
            image: 'debian:13.7-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a',
            imagePullPolicy: 'IfNotPresent',
            command: ['/bin/bash', '/launcher/runtime-launcher.sh'],
            env: [
              { name: 'HOME', value: '/config' },
              { name: 'PUID', value: '1000' },
              { name: 'PGID', value: '1000' },
              { name: 'TZ', value: 'Asia/Tokyo' },
              { name: 'LC_ALL', value: 'ja_JP.UTF-8' },
              { name: 'PIXELFLUX_WAYLAND', value: 'true' },
              { name: 'START_DOCKER', value: 'false' },
              { name: 'SELKIES_ENABLE_BASIC_AUTH', value: 'false' },
              { name: 'SELKIES_MODE', value: 'websockets' },
              { name: 'TITLE', value: 'Linux Desktop' },
              { name: 'UMASK', value: '022' },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 3000,
                protocol: 'TCP',
              },
            ],
            securityContext: {
              runAsUser: 0,
              allowPrivilegeEscalation: true,
              readOnlyRootFilesystem: true,
              appArmorProfile: {
                type: 'Unconfined',
              },
              capabilities: {
                drop: ['ALL'],
                add: [
                  'AUDIT_WRITE',
                  'SYS_ADMIN',
                  'SYS_CHROOT',
                  'CHOWN',
                  'DAC_OVERRIDE',
                  'FOWNER',
                  'FSETID',
                  'KILL',
                  'MKNOD',
                  'NET_BIND_SERVICE',
                  'NET_RAW',
                  'SETPCAP',
                  'SETUID',
                  'SETGID',
                  'SETFCAP',
                ],
              },
            },
            startupProbe: {
              httpGet: {
                path: '/',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 60,
            },
            readinessProbe: {
              httpGet: {
                path: '/',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 6,
            },
            livenessProbe: {
              httpGet: {
                path: '/',
                port: 'http',
              },
              periodSeconds: 60,
              timeoutSeconds: 10,
              failureThreshold: 5,
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
        ],
        volumes: [
          {
            name: 'rootfs',
            persistentVolumeClaim: {
              claimName: (import 'root-pvc.jsonnet').metadata.name,
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
