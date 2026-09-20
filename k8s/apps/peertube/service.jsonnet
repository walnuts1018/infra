local app = import 'app.json5';
local labels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/part-of': app.name,
  'app.kubernetes.io/component': 'server',
};
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    type: 'ClusterIP',
    selector: labels,
    ports: [{ name: 'http', port: 9000, targetPort: 'server', protocol: 'TCP' }],
  },
}
