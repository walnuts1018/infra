(import '../../components/configmap.libsonnet') {
  name: 'kurumi-jwks',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    jwks: (importstr './_configs/kurumi-jwks.json'),  // TODO: 手動コピー
  },
}
