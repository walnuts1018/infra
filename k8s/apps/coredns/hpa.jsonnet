local app = import 'app.json5';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    minReplicaCount: 2,
    maxReplicaCount: 4,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment.jsonnet').metadata.name,
    },
    triggers: [
      {
        type: 'prometheus',
        metadata: {
          serverAddress: 'http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481/select/0/prometheus',
          metricName: 'coredns_dns_requests_total',
          query: 'sum(rate(coredns_dns_requests_total[2m]))',
          threshold: '100',
        },
      },
    ],
  },
}
