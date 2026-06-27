local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'moco',
  repoURL: 'https://cybozu-go.github.io/moco/',
  targetRevision: '0.25.0',
  values: (values),
}
