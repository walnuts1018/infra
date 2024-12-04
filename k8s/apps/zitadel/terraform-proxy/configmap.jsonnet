(import '../../components/configmap.libsonnet') {
  name: (import 'app.libsonnet').name,
  namespace: (import 'app.libsonnet').namespace,
  labels: (import '../../../components/labels.libsonnet') + { appname: (import 'app.libsonnet').name },
  data: {
    'nginx.conf': (importstr './config/nginx.conf'),
    'virtualhost.conf': (importstr './config/virtualhost.conf'),
  },
}
