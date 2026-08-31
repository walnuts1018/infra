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
    minReplicaCount: 1,
    maxReplicaCount: 4,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: 'gha-cache-server-github-actions-cache-server',
    },
    triggers: [
      {
        type: 'prometheus',
        metadata: {
          serverAddress: 'http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481/select/0/prometheus',
          metricName: 'envoy_cluster_upstream_rq_total_gha_cache_server',
          query: 'sum(rate(envoy_cluster_upstream_rq_total{envoy_cluster_name="httproute/arc-systems/gha-cache-server/rule/0",envoy_response_code=~"2..|5.."}[2m]))',
          threshold: '10',
        },
      },
    ],
  },
}
