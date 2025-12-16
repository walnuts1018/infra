(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-emojis',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    'emoji.json': (importstr './config/emoji.json'),
  },
}
