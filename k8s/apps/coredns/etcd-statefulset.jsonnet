local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')('coredns-etcd');
local peerHost(ordinal) =
  'coredns-etcd-%d.coredns-etcd-headless.%s.svc.cluster.local' % [ordinal, app.namespace];
{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name + '-etcd',
    namespace: app.namespace,
    labels: labels,
  },
  spec: {
    replicas: 3,
    serviceName: (import 'etcd-service-headless.jsonnet').metadata.name,
    selector: {
      matchLabels: labels,
    },
    template: {
      metadata: {
        labels: labels,
      },
      spec: {
        affinity: {
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                podAffinityTerm: {
                  labelSelector: {
                    matchLabels: labels,
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet'), {
            name: 'etcd',
            image: 'quay.io/coreos/etcd:v3.5.18',
            command: [
              '/usr/local/bin/etcd',
            ],
            args: [
              '--name=$(POD_NAME)',
              '--data-dir=/var/lib/etcd',
              '--listen-client-urls=http://0.0.0.0:2379',
              '--advertise-client-urls=http://$POD_NAME.coredns-etcd-headless.$POD_NAMESPACE.svc.cluster.local:2379',
              '--listen-peer-urls=http://0.0.0.0:2380',
              '--initial-advertise-peer-urls=http://$POD_NAME.coredns-etcd-headless.$POD_NAMESPACE.svc.cluster.local:2380',
              '--initial-cluster=' + std.join(',', [
                'coredns-etcd-%d=http://%s:2380' % [ordinal, peerHost(ordinal)]
                for ordinal in std.range(0, 2)
              ]),
              '--initial-cluster-token=coredns-etcd',
              '--initial-cluster-state=new',
              '--auto-compaction-mode=periodic',
              '--auto-compaction-retention=1h',
            ],
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
            ports: [
              {
                name: 'client',
                containerPort: 2379,
              },
              {
                name: 'peer',
                containerPort: 2380,
              },
            ],
            livenessProbe: {
              tcpSocket: {
                port: 'client',
              },
            },
            readinessProbe: {
              tcpSocket: {
                port: 'client',
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '512Mi',
              },
            },
            volumeMounts: [
              {
                name: 'data',
                mountPath: '/var/lib/etcd',
              },
            ],
          }),
        ],
      },
    },
    volumeClaimTemplates: [
      {
        metadata: {
          name: 'data',
        },
        spec: {
          accessModes: [
            'ReadWriteOnce',
          ],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '1Gi',
            },
          },
        },
      },
    ],
  },
}
