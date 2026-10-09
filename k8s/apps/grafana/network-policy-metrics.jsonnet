{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'grafana-metrics-collector',
    namespace: 'monitoring',
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'grafana',
        'app.kubernetes.io/instance': 'grafana',
      },
    },
    policyTypes: [
      'Ingress',
    ],
    ingress: [
      {
        from: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'opentelemetry-collector',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/name': 'prometheus-collector',
              },
            },
          },
        ],
        ports: [
          {
            protocol: 'TCP',
            port: 3000,
          },
        ],
      },
    ],
  },
}
