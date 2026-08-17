local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-plans',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'plans.yaml': (importstr './_config/plans.yaml'),
  },
}
