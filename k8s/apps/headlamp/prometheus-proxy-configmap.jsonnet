local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'headlamp-prometheus-proxy',
    namespace: app.namespace,
  },
  data: {
    'nginx.conf': importstr '_config/nginx.conf',
  },
}
