local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'external-dns',
  repoURL: 'https://kubernetes-sigs.github.io/external-dns/',
  targetRevision: '1.22.0',
  values: (importstr 'values.yaml'),
}
