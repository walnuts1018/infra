std.mergePatch((import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-emojis',
  data: {
    'emoji.json': (importstr './config/emoji.json'),
  },
}, {
  metadata: {
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
})
