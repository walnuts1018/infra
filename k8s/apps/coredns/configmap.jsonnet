(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-config',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    Corefile: (importstr './_configs/Corefile'),
    'local.walnuts.dev': (importstr './_configs/local.walnuts.dev'),
  },
}
