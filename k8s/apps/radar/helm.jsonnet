local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'radar',
  repoURL: 'https://skyhook-io.github.io/helm-charts',
  targetRevision: '1.12.1',
  values: (importstr 'values.yaml'),
}
