std.mergePatch((import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'redis-operator',
  repoURL: 'https://ot-container-kit.github.io/helm-charts/',
  targetRevision: '0.18.5',
  values: (importstr 'values.yaml'),
}, {
  spec: {
    syncPolicy: {
      syncOptions: [
        'ServerSideApply=true',
      ],
    },
  },
})