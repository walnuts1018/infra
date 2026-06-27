local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local backup = importstr './_scripts/backup.sh';
local assumerole = importstr './_scripts/assumerole.sh';
(configmap) {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'backup.sh': (backup),
    'assumerole.sh': (assumerole),
  },
}
