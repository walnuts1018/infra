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
        // Operatorによって作られるServiceにMetricPortが定義されていないので、以下のようにして頑張る
        {
          port: component + '-http',  // PodIPを見つけるために、Serviceで定義されているPortの中から適当なものを指定する。このPortからスクレイピングするわけではない
          path: '/metrics',
          relabelings: [
            {
              sourceLabels: ['__address__'],
              targetLabel: '__address__',
              regex: '([^:]+)(?::\\d+)?',
              replacement: '${1}:9327',  // Relabelingの中でPortを固定値に書き換える
            },
          ],
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
