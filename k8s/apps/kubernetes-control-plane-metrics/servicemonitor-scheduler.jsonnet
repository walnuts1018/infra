local app = import 'app.json5';
local authorization = import 'authorization.libsonnet';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'kube-scheduler',
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
        app: 'kube-scheduler-metrics-proxy',
      },
    },
    endpoints: [
      {
        authorization: authorization,
        port: 'http-metrics',
        scheme: 'https',
        tlsConfig: {
          ca: {
            configMap: {
              name: 'kube-root-ca.crt',
              key: 'ca.crt',
            },
          },
          insecureSkipVerify: true,
        },
      },
    ],
  },
}
