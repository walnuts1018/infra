local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-frontend',
    namespace: app.namespace,
    labels: {
      'app.kubernetes.io/name': 'frontend',
      'app.kubernetes.io/part-of': app.name,
    },
  },
  spec: {
    type: 'ClusterIP',
    selector: { 'app.kubernetes.io/name': 'frontend' },
    ports: [{ name: 'http', port: 8080, targetPort: 'http' }],
  },
}
