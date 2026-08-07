local app = import '../pinniped/app.json5';
local httpRoute = import 'httproute.jsonnet';

{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: app.name + '-local-only',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        name: httpRoute.metadata.name,
      },
    ],
    authorization: {
      defaultAction: 'Deny',
      rules: [
        {
          action: 'Allow',
          principal: {
            clientCIDRs: ['192.168.0.0/16'],
          },
        },
      ],
    },
  },
}
