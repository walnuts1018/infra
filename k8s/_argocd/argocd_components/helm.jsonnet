function(domain, ingressClassName='cilium') (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'argo-cd',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '9.0.5',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      global: {
        domain: domain,
      },
      notifications: {
        argocdUrl: 'https://' + domain,
      },
      server: {
        ingress: {
          ingressClassName: ingressClassName,
        },
      },
    }
  ),
}
