local labels = import '../../components/labels.libsonnet';
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
    replicas: 2,
    serviceName: (import 'headless-service.jsonnet').metadata.name,
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        /*
          TODO: 全てのNodeに
          net.ipv4.conf.all.src_valid_mark=1
          net.ipv6.conf.all.forwarding=1
          という内容の /etc/sysctl.d/99-netbird.conf を手動で配置する
        */
        hostNetwork: true,
        dnsPolicy: 'ClusterFirstWithHostNet',
        automountServiceAccountToken: false,
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: (labels)(app.name),
            },
          },
        ],
        containers: [
          {
            name: 'netbird',
            image: 'netbirdio/netbird:0.74.2',
            imagePullPolicy: 'IfNotPresent',
            env: [
              {
                name: 'NB_MANAGEMENT_URL',
                value: 'https://netbird.walnuts.dev:443',
              },
              {
                name: 'NB_SETUP_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'NB_SETUP_KEY',
                  },
                },
              },
              {
                name: 'NB_HOSTNAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.name',
                  },
                },
              },
            ],
            securityContext: {
              readOnlyRootFilesystem: false,
              capabilities: {
                add: [
                  'NET_ADMIN',
                  'NET_BIND_SERVICE',
                  'NET_RAW',
                  'SYS_ADMIN',
                  'SYS_RESOURCE',
                ],
                drop: ['ALL'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            resources: {
              requests: {
                cpu: '20m',
                memory: '64Mi',
              },
              limits: {
                cpu: '500m',
                memory: '256Mi',
              },
            },
            volumeMounts: [
              {
                name: 'state',
                mountPath: '/var/lib/netbird',
              },
              {
                name: 'tun',
                mountPath: '/dev/net/tun',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'tun',
            hostPath: {
              path: '/dev/net/tun',
              type: 'CharDevice',
            },
          },
        ],
      },
    },
    volumeClaimTemplates: [
      {
        metadata: {
          name: 'state',
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '64Mi',
            },
          },
        },
      },
    ],
  },
}
