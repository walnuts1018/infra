local app = import 'app.json5';
local authorization = import 'authorization.libsonnet';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'kube-controller-manager',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    serviceDiscoveryRole: 'EndpointSlice',
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
        authorization: authorization,
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
