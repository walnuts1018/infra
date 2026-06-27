local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = import 'values.libsonnet';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'tenant',
  repoURL: 'https://operator.min.io/',
  targetRevision: '7.1.1',
  valuesObject: (values),
}
