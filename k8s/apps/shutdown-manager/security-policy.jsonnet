{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    targetRef: {
      group: 'gateway.networking.k8s.io',
      kind: 'HTTPRoute',
      name: (import 'httproute.jsonnet').metadata.name,
    },
    jwt: {
      providers: [
        {
          name: 'kurumi-k8s',
          audiences: ['shutdown-manager.local.walnuts.dev'],
          issuer: 'https://kubernetes.default.svc.cluster.local',
          remoteJWKS: {
            uri: 'https://192.168.0.17:16443/.well-known/openid-configuration',
            backendRefs: [
              {
                group: 'gateway.envoyproxy.io',
                kind: 'Backend',
                name: (import 'backend.jsonnet').metadata.name,
                port: 16443,
              },
            ],
          },
          claimToHeaders: [
            {
              claim: 'kubernetes.io/serviceaccount.name',
              header: 'x-k8s-sa-name',
            },
            {
              claim: 'kubernetes.io/namespace',
              header: 'x-k8s-namespace',
            },
          ],
        },
      ],
    },
    authorization: {
      defaultAction: 'Deny',
      rules: [
        {
          action: 'Allow',
          principal: {
            jwt: {
              provider: 'kurumi-k8s',
              claims: [
                {
                  name: 'kubernetes.io.serviceaccount.name',
                  values: [(import '../biscuit-manager/sa.jsonnet').metadata.name],
                },
                {
                  name: 'kubernetes.io.namespace',
                  values: [(import '../biscuit-manager/sa.jsonnet').metadata.namespace],
                },
              ],
            },
          },
        },
      ],
    },
  },
}
