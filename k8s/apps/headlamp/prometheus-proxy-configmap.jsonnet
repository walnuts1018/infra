local app = import 'app.json5';

(import '../../components/configmap.libsonnet') {
  name: 'headlamp-prometheus-proxy',
  namespace: app.namespace,
  labels: {
    'app.kubernetes.io/name': 'headlamp-prometheus-proxy',
  },
  data: {
    'nginx.conf': importstr '_config/nginx.conf',
  },
}
