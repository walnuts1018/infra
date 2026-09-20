local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: { name: app.name, namespace: app.namespace },
  spec: {
    parentRefs: [{ name: 'envoy-gateway', namespace: 'envoy-gateway-system' }],
    hostnames: ['beast.walnuts.dev'],
    rules: [{
      matches: [{ path: { type: 'PathPrefix', value: '/' } }],
      backendRefs: [{ name: app.name + '-frontend', port: 8080 }],
    }],
  },
}
