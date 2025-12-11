(import '../../components/configmap.libsonnet') {
  name: 'scylla-config',
  namespace: (import 'app.json5').namespace,
  data: {
    'scylla.yaml': (importstr './_configs/scylla.yaml'),
  },
}
