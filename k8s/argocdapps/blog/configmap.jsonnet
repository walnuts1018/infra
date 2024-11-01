{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../common/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  data: {
    'nginx.conf': (importstr './config/nginx.conf'),
    'virtualhost.conf': (importstr './config/virtualhost.conf'),
  },
}
