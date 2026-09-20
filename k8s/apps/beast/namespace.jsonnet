local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: app.namespace,
    labels: {
      'app.kubernetes.io/part-of': app.name,
      'pod-security.kubernetes.io/enforce': 'restricted',
      'pod-security.kubernetes.io/audit': 'restricted',
      'pod-security.kubernetes.io/warn': 'restricted',
    },
  },
}
