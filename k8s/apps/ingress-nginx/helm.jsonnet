(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'ingress-nginx',
  repoURL: 'https://kubernetes.github.io/ingress-nginx',
  targetRevision: '4.12.3',
  values: (importstr 'values.yaml'),
}
