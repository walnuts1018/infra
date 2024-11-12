(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'nginx.conf': (importstr './config/nginx.conf'),
    'virtualhost.conf': (importstr './config/virtualhost.conf'),
  },
}
