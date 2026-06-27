local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local assumerole = importstr './_scripts/assumerole.sh';
local backup = importstr './_scripts/backup.sh';
local injectSecretToConfig = importstr './_scripts/inject-secret-to-config.sh';
(configmap) {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'assumerole.sh': (assumerole),
    'backup.sh': (backup),
    'inject-secret-to-config.sh': (injectSecretToConfig),
  },
}
