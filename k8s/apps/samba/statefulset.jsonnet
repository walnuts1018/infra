local labels = import '../../components/labels.libsonnet';
local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    selector: {
      matchLabels: labels(app.name),
    },
    serviceName: (import 'service.jsonnet').metadata.name,
    replicas: 1,
    template: {
      metadata: {
        labels: labels(app.name),
        annotations: {
          'checksum/samba-monitor-config': std.md5(std.toString((import 'monitor-configmap.jsonnet').data)),
        },
      },
      spec: {
        affinity: storage.avoidSlowNodeAffinity,
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          (import '../../components/container.libsonnet') {
            image: 'ghcr.io/servercontainers/samba:a3.24.2-s4.23.8-r0@sha256:ea1b37536729f16b2f45a601ea45a37d34b9fce5cc51f2d686a347dd77131be1',
            imagePullPolicy: 'IfNotPresent',
            name: 'samba',
            command: ['/bin/sh', '/config/samba-entrypoint.sh'],
            args: ['runsvdir', '-P', '/container/config/runit'],
            env: [
              {
                name: 'ACCOUNT_samba',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'account-samba',
                  },
                },
              },
              {
                name: 'SAMBA_CONF_LOG_LEVEL',
                value: '3',
              },
              {
                name: 'WSDD2_DISABLE',
                value: '1',
              },
              {
                name: 'AVAHI_DISABLE',
                value: '1',
              },
              {
                name: 'GROUPS_samba',
                value: 'samba',
              },
              {
                name: 'SAMBA_VOLUME_CONFIG_share',
                value: '[share]; path=/samba-share; valid users = samba; public = no; read only = no; browseable = yes; available = yes',
              },
              {
                name: 'SAMBA_GLOBAL_CONFIG_smb_SPACE_ports',
                value: '10445 10139',
              },
            ],
            ports: [
              {
                containerPort: 10445,
                name: 'samba',
              },
            ],
            volumeMounts: [
              {
                name: 'root',
                mountPath: '/samba-share',
              },
              {
                name: 'monitor-entrypoint',
                mountPath: '/config',
                readOnly: true,
              },
              {
                name: 'monitor-credentials',
                mountPath: '/run/secrets',
                readOnly: true,
              },
              {
                name: 'books',
                mountPath: '/samba-share/books',
              },
              {
                name: 'camera-roll',
                mountPath: '/samba-share/CameraRoll',
              },
              {
                name: 'mega',
                mountPath: '/samba-share/mega',
              },
              {
                name: 'movies',
                mountPath: '/samba-share/movies',
              },
              {
                name: 'musics',
                mountPath: '/samba-share/musics',
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '6Gi',
              },
            },
            securityContext:: null,
          },
        ],
        volumes: [
          {
            name: 'monitor-entrypoint',
            configMap: {
              name: 'samba-monitor',
            },
          },
          {
            name: 'monitor-credentials',
            secret: {
              secretName: (import 'external-secret.jsonnet').spec.target.name,
              defaultMode: 288,
              items: [
                {
                  key: 'monitor-username',
                  path: 'username',
                },
                {
                  key: 'monitor-password',
                  path: 'password',
                },
              ],
            },
          },
          {
            name: 'root',
            persistentVolumeClaim: {
              claimName: (import 'pvc-root.jsonnet').metadata.name,
            },
          },
          {
            name: 'books',
            persistentVolumeClaim: {
              claimName: (import 'pvc-books.jsonnet').metadata.name,
            },
          },
          {
            name: 'camera-roll',
            persistentVolumeClaim: {
              claimName: (import 'pvc-camera-roll.jsonnet').metadata.name,
            },
          },
          {
            name: 'mega',
            persistentVolumeClaim: {
              claimName: (import 'pvc-mega.jsonnet').metadata.name,
            },
          },
          {
            name: 'movies',
            persistentVolumeClaim: {
              claimName: (import 'pvc-movies.jsonnet').metadata.name,
            },
          },
          {
            name: 'musics',
            persistentVolumeClaim: {
              claimName: (import 'pvc-musics.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
