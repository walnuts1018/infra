local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: { name: app.name + '-auth', namespace: app.namespace },
  spec: {
    parentRefs: [{ name: 'envoy-gateway', namespace: 'envoy-gateway-system' }],
    hostnames: ['beast.walnuts.dev'],
    rules: [{
      matches: [
        { path: { type: 'Exact', value: '/api/auth/mobile/login' } },
        { path: { type: 'Exact', value: '/api/auth/callback' } },
      ],
      timeouts: { request: '0s', backendRequest: '0s' },
      backendRefs: [{ name: app.name + '-apiserver', port: 8080 }],
    }],
  },
}
