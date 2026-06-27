local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
local pvcBooks = import 'pvc-books.jsonnet';
local pvcCameraRoll = import 'pvc-camera-roll.jsonnet';
local pvcMega = import 'pvc-mega.jsonnet';
local pvcMovies = import 'pvc-movies.jsonnet';
local pvcMusics = import 'pvc-musics.jsonnet';
local pvcRoot = import 'pvc-root.jsonnet';
local service = import 'service.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    selector: {
      matchLabels: (labels)(app.name),
    },
    serviceName: service.metadata.name,
    replicas: 1,
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          (container) {
            image: 'ghcr.io/servercontainers/samba:a3.24.1-s4.23.8-r0',
            imagePullPolicy: 'IfNotPresent',
            name: 'samba',
            env: [
              {
                name: 'ACCOUNT_samba',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
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
              claimName: pvcRoot.metadata.name,
            },
          },
          {
            name: 'books',
            persistentVolumeClaim: {
              claimName: pvcBooks.metadata.name,
            },
          },
          {
            name: 'camera-roll',
            persistentVolumeClaim: {
              claimName: pvcCameraRoll.metadata.name,
            },
          },
          {
            name: 'mega',
            persistentVolumeClaim: {
              claimName: pvcMega.metadata.name,
            },
          },
          {
            name: 'movies',
            persistentVolumeClaim: {
              claimName: pvcMovies.metadata.name,
            },
          },
          {
            name: 'musics',
            persistentVolumeClaim: {
              claimName: pvcMusics.metadata.name,
            },
          },
        ],
      },
    },
  },
}
