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
        extraArgs: [
          '--tls-cert-path=/app/config/tls/tls.crt',
          '--tls-key-path=/app/config/tls/tls.key',
        ],
        volumeMounts: [
          {
            name: 'tls',
            mountPath: '/app/config/tls',
            readOnly: true,
          },
        ],
        volumes: [
          {
            name: 'tls',
            secret: {
              secretName: 'argocd-server-tls',
            },
          },
        ],
        httproute: {
          enabled: true,
          parentRefs: [
            {
              name: 'envoy-gateway',
              namespace: 'envoy-gateway-system',
            },
          ],
          hostnames: [domain],
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
