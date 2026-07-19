local app = import 'app.json5';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: {
    name: app.appname.backend,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.appname.backend),
  },
  spec: {
    minReplicaCount: 2,
    maxReplicaCount: 5,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment-backend.jsonnet').metadata.name,
    },
    triggers: [
      {
        type: 'prometheus',
        metadata: {
          serverAddress: 'http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481/select/0/prometheus',
          metricName: 'envoy_cluster_upstream_rq_total_backend',
          query: 'sum(rate(cluster_upstream_rq_total{envoy_cluster_name="httproute/walnuk/walnuk/rule/0"}[2m]))',
          threshold: '15',
        },
      },
    ],
  },
}
