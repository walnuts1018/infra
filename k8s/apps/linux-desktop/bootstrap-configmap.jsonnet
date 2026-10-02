local configmap = import '../../components/configmap.libsonnet';
local app = import 'app.json5';
configmap {
  name: app.name + '-bootstrap',
  namespace: app.namespace,
  use_suffix: true,
  data: {
    'bootstrap.sh': importstr '_scripts/bootstrap.sh',
    'configure-rootfs.sh': importstr '_scripts/configure-rootfs.sh',
  },
  metadata+: {
    annotations: {
      'argocd.argoproj.io/sync-wave': '-2',
    },
  },
}
