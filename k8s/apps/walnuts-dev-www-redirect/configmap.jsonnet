{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name + '-' + std.md5(std.toString($.data))[0:6],
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  data: {
    'nginx.conf': (importstr './config/nginx.conf'),
    'virtualhost.conf': (importstr './config/virtualhost.conf'),
  },
}
