local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
function(domain, ingressClassName='cilium', enableHPA=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'argo-cd',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '10.3.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      global: {
        domain: domain,
      },
      configs: {
        params: {
          'server.insecure': false,
        },
      },
      notifications: {
        argocdUrl: 'https://' + domain,
      },
      server: {
        certificate: {
          enabled: true,
          domain: domain,
          issuer: {
            group: 'cert-manager.io',
            kind: 'ClusterIssuer',
            name: 'letsencrypt-prod',
          },
        },
        ingress: {
          enabled: false,
        },
        httproute: {
          enabled: true,
          parentRefs: [
            {
              name: 'envoy-gateway',
              namespace: 'envoy-gateway-system',
            },
          ],
          hostnames: [domain],
          validation: {
            hostname: domain,
            wellKnownCACertificates: 'System',
          },
        },
        grpcroute: {
          enabled: true,
          parentRefs: [
            {
              name: 'envoy-gateway',
              namespace: 'envoy-gateway-system',
            },
          ],
          hostnames: [domain],
          rules: [{}],
          validation: {
            hostname: domain,
            wellKnownCACertificates: 'System',
          },
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
