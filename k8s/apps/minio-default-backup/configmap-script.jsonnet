(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    'backup.sh': (importstr './_scripts/backup.sh'),
    'assumerole.sh': (importstr './_scripts/assumerole.sh'),
  },
}
