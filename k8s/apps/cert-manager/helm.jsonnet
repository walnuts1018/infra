(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cert-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v1.16.2',
  valuesObject: {
    installCRDs: true,
  },
}
