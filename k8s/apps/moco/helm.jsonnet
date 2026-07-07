local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'moco',
  repoURL: 'https://cybozu-go.github.io/moco/',
  targetRevision: '0.26.0',
  values: (importstr 'values.yaml'),
}
