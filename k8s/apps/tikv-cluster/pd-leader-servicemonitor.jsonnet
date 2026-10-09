local app = import 'app.json5';
local workloadLabels = {
  'app.kubernetes.io/name': 'pd-leader-prober',
  'app.kubernetes.io/instance': app.name,
};
local target = 'https://tikv-cluster-pd-peer.databases.svc.cluster.local:2379/pd/api/v1/leader';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name + '-pd-leader-prober',
    namespace: app.namespace,
    labels: {
      'walnuts.dev/scraped-by': 'pd-leader-prober',
    },
  },
  spec: {
    selector: {
      matchLabels: workloadLabels,
    },
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    endpoints: [
      {
        port: 'http',
        path: '/probe',
        scheme: 'http',
        interval: '30s',
        scrapeTimeout: '10s',
        params: {
          module: ['http_pd_leader'],
          target: [target],
        },
        metricRelabelings: [
          {
            action: 'replace',
            replacement: target,
            targetLabel: 'instance',
          },
          {
            action: 'replace',
            replacement: 'pd-leader',
            targetLabel: 'target',
          },
        ],
      },
    ],
  },
}
