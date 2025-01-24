(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'ghcr.io/openclarity/charts/openclarity',
  targetRevision: '1.1.2',
  values: (importstr 'values.yaml'),
}

// {
//   apiVersion: 'argoproj.io/v1alpha1',
//   kind: 'Application',
//   metadata: {
//     name: (import 'app.json5').name + '-helm',
//     namespace: 'argocd',
//   },
//   spec: {
//     project: 'default',
//     destination: {
//       namespace: (import 'app.json5').namespace,
//       server: 'https://kubernetes.default.svc',
//     },
//     source: {
//       path: 'k8s/apps/openclarity/_kustomize',
//       repoURL: 'https://github.com/walnuts1018/infra',
//       targetRevision: 'main',
//     },
//     syncPolicy: {
//       automated: {
//         selfHeal: true,
//         prune: true,
//       },
//     },
//   },
// }
