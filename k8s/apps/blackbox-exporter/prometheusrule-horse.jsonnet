{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PrometheusRule',
  metadata: {
    name: 'blackbox-alerts-horse',
    namespace: 'monitoring',
    labels: { release: 'prometheus-stack' },
  },
  spec: {
    groups: [
      {
        name: 'horse.public-probe',
        rules: [
          {
            alert: 'HorsePublicProbeFailed',
            expr: 'probe_success{target="horse"} == 0',
            'for': '5m',
            labels: { severity: 'warning' },
            annotations: {
              summary: 'Horse public health probe is failing',
              description: 'The Blackbox probe for {{ $labels.instance }} has failed continuously for 5 minutes.',
            },
          },
        ],
      },
    ],
  },
}
