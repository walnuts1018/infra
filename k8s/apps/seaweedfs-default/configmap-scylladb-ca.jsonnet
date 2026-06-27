local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local ca = importstr './_configs/ca.crt';
(configmap) {
  name: app.name + '-scylladb-ca-cert',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'ca.crt': (ca),  // TODO: database namespaceから撮ってきたけど良い方法を考えないといけない
  },
}
