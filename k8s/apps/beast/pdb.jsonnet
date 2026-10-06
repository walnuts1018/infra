local app = import 'app.json5';
{
  apiVersion: 'policy/v1',
  kind: 'PodDisruptionBudget',
  metadata: { name: app.name + '-backend', namespace: app.namespace },
  spec: {
    minAvailable: 1,
    selector: { matchLabels: { 'app.kubernetes.io/name': 'backend' } },
  },
}
