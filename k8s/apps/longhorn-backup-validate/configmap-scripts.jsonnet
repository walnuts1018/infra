(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-scripts',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'validate-longhorn-backup.sh': (importstr './_scripts/validate-longhorn-backup.sh'),
  },
}
