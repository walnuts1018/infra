local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local rclone = importstr './_config/rclone.conf';
(configmap) {
  name: app.name + '-rclone',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'rclone.conf.template': (rclone),
  },
}
