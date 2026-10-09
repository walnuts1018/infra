local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name + '-pd',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/component': 'pd',
        'app.kubernetes.io/instance': app.name,
      },
    },
    podMetricsEndpoints: [
      {
        portNumber: 2379,
        path: '/metrics',
        scheme: 'https',
        interval: '30s',
        tlsConfig: {
          ca: {
            secret: {
              name: 'tikv-cluster-pd-cluster-secret',
              key: 'ca.crt',
            },
          },
          cert: {
            secret: {
              name: 'tikv-cluster-pd-cluster-secret',
              key: 'tls.crt',
            },
          },
          keySecret: {
            name: 'tikv-cluster-pd-cluster-secret',
            key: 'tls.key',
          },
          serverName: 'tikv-cluster-pd-peer.databases.svc.cluster.local',
        },
      },
    ],
  },
}
