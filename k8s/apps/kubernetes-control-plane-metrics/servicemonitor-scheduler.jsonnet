local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'kube-scheduler',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    jobLabel: 'jobLabel',
    namespaceSelector: {
      matchNames: ['kube-system'],
    },
    selector: {
      matchLabels: {
        app: 'kube-scheduler-metrics-proxy',
      },
    },
    endpoints: [
      {
        bearerTokenFile: '/var/run/secrets/kubernetes.io/serviceaccount/token',
        port: 'http-metrics',
        scheme: 'https',
        tlsConfig: {
          caFile: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt',
          insecureSkipVerify: true,
        },
      },
    ],
  },
}
