local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    Corefile: (importstr './_configs/Corefile'),
  },
}
