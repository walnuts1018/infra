local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    podMetricsEndpoints: [
      {
        targetPort: 8080,
        path: '/metrics',
        interval: '15s',
      },
    ],
    selector: {
      matchExpressions: [
        {
          key: 'actions.github.com/scale-set-name',
          operator: 'Exists',
        },
      ],
    },
  },
}
