local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'opencost',
  repoURL: 'https://opencost.github.io/opencost-helm-chart',
  targetRevision: '2.5.23',
  values: (values),
}
