std.mergePatch((import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  data: {
    'backup.sh': (importstr './config/backup.sh'),
  },
}, {
  metadata: {
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
})
