local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'valkey-operator',
  repoURL: 'https://valkey.io/valkey-helm/',
  targetRevision: '0.3.2',
  values: (importstr 'values.yaml'),
}
