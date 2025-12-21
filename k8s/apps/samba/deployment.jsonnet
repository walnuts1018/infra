{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    strategy: {
      type: 'Recreate',
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          (import '../../components/container.libsonnet') {
            image: 'ghcr.io/servercontainers/samba:a3.23.2-s4.22.6-r0',  // TODO: renovate
            imagePullPolicy: 'IfNotPresent',
            name: 'samba',
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
                memory: '1Gi',
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
            name: 'samba-local-dir',
            hostPath: {
              path: '/mnt/data/share',
              type: 'Directory',
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
