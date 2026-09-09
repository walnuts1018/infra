local app = import 'app.json5';
local backup = importstr './_scripts/backup.sh';
local assumerole = importstr './_scripts/assumerole.sh';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'backup.sh': (backup),
    'assumerole.sh': (assumerole),
  },
}
