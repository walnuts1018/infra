local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local Corefile = importstr './_configs/Corefile';
(configmap) {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    Corefile: (Corefile),
  },
}
