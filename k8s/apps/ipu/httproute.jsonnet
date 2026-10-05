local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '0',
    },
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      'ipu.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            name: app.name,
            port: 8080,
          },
        ],
      },
    ],
  },
}
