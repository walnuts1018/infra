local app = import 'app.json5';
local ca = importstr './_configs/ca.crt';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-scylladb-ca-cert',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'ca.crt': (ca),  // TODO: database namespaceから撮ってきたけど良い方法を考えないといけない
  },
}
