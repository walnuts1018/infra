local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local waitMinioDefaultBackup = importstr './_scripts/wait_minio-default-backup.sh';
local triggerAndWaitMinioBiscuitBackup = importstr './_scripts/trigger_and_wait_minio-biscuit-backup.sh';
(configmap) {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'wait_minio-default-backup.sh': (waitMinioDefaultBackup),
    'trigger_and_wait_minio-biscuit-backup.sh': (triggerAndWaitMinioBiscuitBackup),
  },
}
