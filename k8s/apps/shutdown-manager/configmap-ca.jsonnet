(import '../../components/configmap.libsonnet') {
  name: 'kurumi-ca',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    'ca.crt': (importstr './_configs/kurumi-ca.crt'),  // TODO: 手動コピー
  },
}
