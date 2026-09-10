local app = import 'app.json5';
local backup = importstr './_scripts/backup.py';
local assumerole = importstr './_scripts/assumerole.py';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'backup.py': (backup),
    'assumerole.py': (assumerole),
  },
}
