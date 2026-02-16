(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-scylladb-ca-cert',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    'ca.crt': (importstr './_config/ca.crt'),  // database namespaceから撮ってきたけど良い方法を考えないといけない
  },
}
