(import '../../components/configmap.libsonnet') {
  name: 'scylla-setup',
  namespace: (import 'app.json5').namespace,
  data: {
    'setup.sh': (importstr './_scripts/setup.sh'),
    'keyspaces.cql': (importstr './_configs/keyspaces.cql'),
  },
}
