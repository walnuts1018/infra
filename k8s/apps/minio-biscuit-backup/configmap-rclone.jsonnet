(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-rclone',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'rclone.conf.template': (importstr './_config/rclone.conf'),
  },
}
