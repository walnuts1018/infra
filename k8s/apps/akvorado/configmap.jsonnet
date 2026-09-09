local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: 'akvorado-config',
  namespace: app.namespace,
  labels: labels('akvorado-config'),
  data: {
    'akvorado.yaml': (importstr '_configs/akvorado.yaml'),
    'inlet.yaml': (importstr '_configs/inlet.yaml'),
    'outlet.yaml': (importstr '_configs/outlet.yaml'),
    'console.yaml': (importstr '_configs/console.yaml'),
  },
}
