local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-aws',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    config: (importstr './_config/aws-config'),
  },
}
