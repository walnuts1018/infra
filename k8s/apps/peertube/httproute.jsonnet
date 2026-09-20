local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [{ name: gateway.metadata.name, namespace: gateway.metadata.namespace }],
    hostnames: ['peertube.walnuts.dev'],
    rules: [{
      matches: [{ path: { type: 'PathPrefix', value: '/' } }],
      backendRefs: [{ name: app.name, port: 9000 }],
      timeouts: { request: '1h' },
    }],
  },
}
