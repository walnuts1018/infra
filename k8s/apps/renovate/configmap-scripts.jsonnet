local app = import 'app.json5';

(import '../../components/configmap.libsonnet') {
  name: app.name + '-scripts',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'disk-cleaner.sh': (importstr './_scripts/disk-cleaner.sh'),
  },
}
