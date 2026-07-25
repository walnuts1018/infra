local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
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
        // The peer must use the node's LAN routing table to reach both subnets.
        hostNetwork: true,
        dnsPolicy: 'ClusterFirstWithHostNet',
        automountServiceAccountToken: false,
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
                name: 'netbird-state',
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
            name: 'netbird-state',
            emptyDir: {},
          },
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
  },
}
