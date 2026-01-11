[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata: {
      name: (import 'app.json5').name + '-' + component,
      namespace: (import 'app.json5').namespace,
      labels: (import '../../components/labels.libsonnet')($.metadata.name),
    },
    spec: {
      selector: {
        matchLabels: {
          'app.kubernetes.io/name': 'seaweedfs',
          'app.kubernetes.io/instance': (import 'app.json5').name,
          'app.kubernetes.io/component': component,
        },
        matchExpressions: [
          {
            key: 'prometheus.io/service-monitor',
            operator: 'NotIn',
            values: ['false'],
          },
        ],
      },
      endpoints: [
        {
          port: 9327,
          path: '/metrics',
        },
      ],
    },
  }
  for component in [
    'master',
    'volume',
    'filer',
  ]
]
