{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name + '-config',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  data: {
    'config.yaml': (importstr './config/config.yaml'),
  },
}
