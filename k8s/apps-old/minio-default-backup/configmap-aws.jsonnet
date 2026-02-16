(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-aws',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    config: (importstr './_config/aws-config'),
  },
}
