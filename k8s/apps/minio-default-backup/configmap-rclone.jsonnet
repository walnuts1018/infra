local app = import 'app.json5';
local rclone = importstr './_config/rclone.conf';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-rclone',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'rclone.conf': (rclone),
  },
}
