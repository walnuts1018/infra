local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local Corefile = importstr './_configs/Corefile';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    Corefile: (Corefile),
  },
}
