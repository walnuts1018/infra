local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
function(domain, ingressClassName='cilium', enableHPA=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'argo-cd',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '9.5.22',
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
        autoscaling: {
          enabled: enableHPA,
        },
      },
      repoServer: {
        autoscaling: {
          enabled: enableHPA,
        },
      },
    }
  ),
}
