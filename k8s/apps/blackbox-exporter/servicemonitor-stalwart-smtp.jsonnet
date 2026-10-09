{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'blackbox-alerts-stalwart-smtp',
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
            replacement: 'envoy-envoy-gateway-system-envoy-gateway-dc2b3bc0.envoy-gateway-system.svc.cluster.local:25',
            sourceLabels: [
              'instance',
            ],
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'stalwart-smtp',
            sourceLabels: [
              'target',
            ],
            targetLabel: 'target',
          },
        ],
        params: {
          module: [
            'smtp_starttls',
          ],
          target: [
            'envoy-envoy-gateway-system-envoy-gateway-dc2b3bc0.envoy-gateway-system.svc.cluster.local:25',
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
