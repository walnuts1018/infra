(import '../../components/configmap.libsonnet') {
  name: 'kurumi-jwks',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    jwks: (importstr './_configs/kurumi-jwks.json'),
  },
}
