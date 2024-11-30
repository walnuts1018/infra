(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'affine.js': (importstr './config/affine.js'),
  },
}
