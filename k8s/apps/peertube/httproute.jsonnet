local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local service = import 'service.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: ['peertube.walnuts.dev'],
    rules: [{
      matches: [
        {
          path: {
            type: 'PathPrefix',
            value: '/',
          },
        },
      ],
      backendRefs: [
        {
          name: service.metadata.name,
          port: service.spec.ports[0].port,
        },
      ],
      timeouts: { request: '1h' },
    }],
  },
}
