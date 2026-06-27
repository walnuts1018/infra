local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-aws',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    config: (importstr './_config/aws-config'),
  },
}
