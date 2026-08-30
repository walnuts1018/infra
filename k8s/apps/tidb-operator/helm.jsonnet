local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'tidb-operator',
  repoURL: 'https://charts.pingcap.com/',
  targetRevision: 'v1.6.6',
  valuesObject: {
    scheduler: {
      create: false,
    },
  },
}
