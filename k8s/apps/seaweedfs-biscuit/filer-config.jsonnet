local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-filer-config',
    namespace: app.namespace,
    labels: labels(app.name) + {
      'app.kubernetes.io/component': 'mini',
    },
  },
  data: {
    'filer.toml': |||
      [leveldb2]
      enabled = true
      dir = "/meta/filer"
    |||,
  },
}
