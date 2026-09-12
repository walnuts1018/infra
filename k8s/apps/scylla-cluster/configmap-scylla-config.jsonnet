local scylla = importstr './_configs/scylla.yaml';
(import '../../components/configmap.libsonnet') {
  name: 'scylla-config',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: {
    'scylla.yaml': (scylla),
  },
}
