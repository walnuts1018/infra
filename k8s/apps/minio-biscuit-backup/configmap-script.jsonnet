(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'assumerole.sh': (importstr './_scripts/assumerole.sh'),
    'backup.sh': (importstr './_scripts/backup.sh'),
    'inject-secret-to-config.sh': (importstr './_scripts/inject-secret-to-config.sh'),
  },
}
