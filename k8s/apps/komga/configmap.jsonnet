{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name + '-secret-template' + '-' + std.md5(std.toString($.data))[0:6],
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  data: {
    'application.yml': (importstr './config/application.yml'),
  },
}
