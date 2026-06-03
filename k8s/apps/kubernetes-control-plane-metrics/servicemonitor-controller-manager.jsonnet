local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'kube-controller-manager',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    jobLabel: 'jobLabel',
    namespaceSelector: {
      matchNames: ['kube-system'],
    },
    selector: {
      matchLabels: {
        app: 'kube-controller-manager-metrics-proxy',
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
