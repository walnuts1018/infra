local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name + '-tikv',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/component': 'tikv',
        'app.kubernetes.io/instance': app.name,
      },
    },
    podMetricsEndpoints: [
      {
        port: 'server',
        path: '/metrics',
        scheme: 'https',
        interval: '30s',
        relabelings: [
          {
            sourceLabels: ['__address__'],
            regex: '(.+):20160',
            targetLabel: '__address__',
            replacement: '$1:20180',
          },
        ],
        tlsConfig: {
          ca: {
            secret: {
              name: 'tikv-cluster-tikv-cluster-secret',
              key: 'ca.crt',
            },
          },
          cert: {
            secret: {
              name: 'tikv-cluster-tikv-cluster-secret',
              key: 'tls.crt',
            },
          },
          keySecret: {
            name: 'tikv-cluster-tikv-cluster-secret',
            key: 'tls.key',
          },
          serverName: 'tikv-cluster-tikv-peer.databases.svc.cluster.local',
        },
      },
    ],
  },
}
