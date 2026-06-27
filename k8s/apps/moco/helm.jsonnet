local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'moco',
  repoURL: 'https://cybozu-go.github.io/moco/',
  targetRevision: '0.25.0',
  values: (values),
}
