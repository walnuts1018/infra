{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'blackbox-alerts-mcl-playground',
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
            replacement: 'http://mcl-playground-api.mcl-website.svc.cluster.local:8080/healthz',
            sourceLabels: ['instance'],
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'mcl-playground-api',
            sourceLabels: ['target'],
            targetLabel: 'target',
          },
        ],
        params: {
          module: ['http_2xx'],
          target: ['http://mcl-playground-api.mcl-website.svc.cluster.local:8080/healthz'],
        },
        path: '/probe',
        port: 'http',
        scheme: 'http',
        scrapeTimeout: '10s',
      },
      {
        honorTimestamps: true,
        interval: '30s',
        metricRelabelings: [
          {
            action: 'replace',
            replacement: 'https://mcl.walnuts.dev/playground/',
            sourceLabels: ['instance'],
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'mcl-playground-website',
            sourceLabels: ['target'],
            targetLabel: 'target',
          },
        ],
        params: {
          module: ['http_2xx'],
          target: ['https://mcl.walnuts.dev/playground/'],
        },
        path: '/probe',
        port: 'http',
        scheme: 'http',
        scrapeTimeout: '10s',
      },
    ],
    jobLabel: 'blackbox-exporter',
    namespaceSelector: { matchNames: ['monitoring'] },
    selector: {
      matchLabels: {
        'app.kubernetes.io/instance': 'blackbox-exporter',
        'app.kubernetes.io/name': 'prometheus-blackbox-exporter',
      },
    },
  },
}
