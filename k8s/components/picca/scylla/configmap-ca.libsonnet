function(app, useSuffix=true) (import '../../configmap.libsonnet') {
  name: app.name + '-scylladb-ca-cert',
  namespace: app.namespace,
  use_suffix: useSuffix,
  labels: (import '../../labels.libsonnet')(app.name),
  data: {
    'ca.crt': (importstr 'ca.crt'),  // TODO: database namespaceから撮ってきたけど良い方法を考えないといけない
  },
}
