local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local clientMetricsConfig = import 'client-metrics-configmap.jsonnet';
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
        annotations: {
          'checksum/client-metrics': std.md5(std.toString(clientMetricsConfig.data)),
        },
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
              matchLabels: labels(app.name),
            },
          },
        ],
        containers: [
          {
            name: 'netbird',
            image: 'netbirdio/netbird:0.80.0@sha256:4976692ea44bb93871743d0b742b4a8f97f6425bfc458ca2d78e28fdb8bdf4ad',
            imagePullPolicy: 'IfNotPresent',
            env: [
              {
                name: 'NETBIRD_BIN',
                value: '/etc/netbird-monitoring/netbird-cli-wrapper.sh',
              },
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
              allowPrivilegeEscalation: false,
              capabilities: {
                add: [
                  'NET_ADMIN',
                  'NET_RAW',
                ],
                drop: ['ALL'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '64Mi',
              },
              limits: {
                memory: '256Mi',
              },
            },
            volumeMounts: [
              {
                name: 'client-metrics-config',
                mountPath: '/etc/netbird-monitoring',
                readOnly: true,
              },
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
          {
            name: 'client-metrics-collector',
            image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.162.0@sha256:39923a8e431bd1f57be82411999d389fcfe40857492e4365456d97a4c1f74be6',
            imagePullPolicy: 'IfNotPresent',
            args: ['--config=/etc/netbird-monitoring/collector.yaml'],
            env: [
              {
                name: 'POD_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.name',
                  },
                },
              },
              {
                name: 'POD_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
            ],
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 10001,
              runAsGroup: 10001,
              readOnlyRootFilesystem: true,
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '64Mi',
              },
              limits: {
                cpu: '100m',
                memory: '128Mi',
              },
            },
            volumeMounts: [
              {
                name: 'client-metrics-config',
                mountPath: '/etc/netbird-monitoring',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'client-metrics-config',
            configMap: {
              name: clientMetricsConfig.metadata.name,
              defaultMode: 365,
            },
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
