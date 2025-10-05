(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'start.sh': (importstr './_scripts/start.sh'),
    'shutdown.sh': (importstr './_scripts/shutdown.sh'),
  },
}
