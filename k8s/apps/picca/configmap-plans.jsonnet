local app = import 'app.json5';
local plans = importstr './_config/plans.yaml';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-plans',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'plans.yaml': plans,
  },
}
