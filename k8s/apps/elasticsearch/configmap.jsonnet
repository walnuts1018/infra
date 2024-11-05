(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'elasticsearch-plugins.yml': (importstr './config/elasticsearch-plugins.yml'),
  },
}
