local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-apiserver',
    namespace: app.namespace,
    labels: {
      'app.kubernetes.io/name': 'backend',
      'app.kubernetes.io/part-of': app.name,
    },
  },
  spec: {
    type: 'ClusterIP',
    selector: { 'app.kubernetes.io/name': 'backend' },
    ports: [{ name: 'http', port: 8080, targetPort: 'http' }],
  },
}
