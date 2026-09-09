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
      name: 'zitadel',
    },
    triggers: [
      {
        type: 'prometheus',
        metadata: {
          serverAddress: 'http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481/select/0/prometheus',
          metricName: 'http_server_request_count_total_zitadel',
          query: 'sum(rate(http_server_request_count_total{namespace="zitadel", service_name="zitadel"}[2m]))',
          threshold: '10',
        },
      },
    ],
  },
}
