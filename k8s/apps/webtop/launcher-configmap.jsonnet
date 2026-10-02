local configmap = import '../../components/configmap.libsonnet';
local app = import 'app.json5';
configmap {
  name: app.name + '-launcher',
  namespace: app.namespace,
  use_suffix: true,
  data: {
    'runtime-launcher.sh': importstr '_scripts/runtime-launcher.sh',
  },
  metadata+: {
    annotations: {
      'argocd.argoproj.io/sync-wave': '-2',
    },
  },
}
