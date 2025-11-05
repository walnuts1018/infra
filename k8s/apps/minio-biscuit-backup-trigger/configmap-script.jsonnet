(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'wait_minio-default-backup.sh': (importstr './_scripts/wait_minio-default-backup.sh'),
  },
}
