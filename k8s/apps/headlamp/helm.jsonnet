local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'headlamp',
  repoURL: 'https://kubernetes-sigs.github.io/headlamp/',
  targetRevision: '0.44.0',
  values: (importstr 'values.yaml'),
}
