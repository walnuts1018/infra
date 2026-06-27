local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'wait_minio-default-backup.sh': (importstr './_scripts/wait_minio-default-backup.sh'),
    'trigger_and_wait_minio-biscuit-backup.sh': (importstr './_scripts/trigger_and_wait_minio-biscuit-backup.sh'),
  },
}
