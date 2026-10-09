{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'blackbox-alerts-coder',
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
            replacement: 'https://coder.walnuts.dev/healthz',
            sourceLabels: [
              'instance',
            ],
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'coder',
            sourceLabels: [
              'target',
            ],
            targetLabel: 'target',
          },
        ],
        params: {
          module: [
            'http_2xx',
          ],
          target: [
            'https://coder.walnuts.dev/healthz',
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
