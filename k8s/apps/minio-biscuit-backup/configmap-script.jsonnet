local app = import 'app.json5';
local assumerole = importstr './_scripts/assumerole.sh';
local backup = importstr './_scripts/backup.sh';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'assumerole.sh': (assumerole),
    'backup.sh': (backup),
    'inject-secret-to-config.sh': (importstr './_scripts/inject-secret-to-config.sh'),
  },
}
