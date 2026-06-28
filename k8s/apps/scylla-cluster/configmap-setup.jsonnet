local setup = importstr './_scripts/setup.sh';
(import '../../components/configmap.libsonnet') {
  name: 'scylla-setup',
  namespace: (import 'app.json5').namespace,
  data: {
    'setup.sh': (setup),
  },
}
