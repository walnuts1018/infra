{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'blackbox-alerts-stalwart-imaps',
    namespace: 'monitoring',
  },
  spec: {
    endpoints: [
      {
        honorTimestamps: true,
        interval: '30s',
        metricRelabelings: [
          {
            action: 'replace',
            replacement: 'envoy-envoy-gateway-system-envoy-gateway-dc2b3bc0.envoy-gateway-system.svc.cluster.local:993',
            sourceLabels: [
              'instance',
            ],
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'stalwart-imaps',
            sourceLabels: [
              'target',
            ],
            targetLabel: 'target',
          },
        ],
        params: {
          module: [
            'imaps',
          ],
          target: [
            'envoy-envoy-gateway-system-envoy-gateway-dc2b3bc0.envoy-gateway-system.svc.cluster.local:993',
          ],
        },
        path: '/probe',
        port: 'http',
        scheme: 'http',
        scrapeTimeout: '30s',
      },
    ],
    jobLabel: 'blackbox-exporter',
    namespaceSelector: {
      matchNames: [
        'monitoring',
      ],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/instance': 'blackbox-exporter',
        'app.kubernetes.io/name': 'prometheus-blackbox-exporter',
      },
    },
  },
}
