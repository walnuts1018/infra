local app = import 'app.json5';
local gateway = import '../envoy-gateway-class/gateway.jsonnet';

{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '2',
      'external-dns-cloudflare.alpha.kubernetes.io/cloudflare-proxied': 'true',
    },
  },
  spec: {
    parentRefs: [{
      name: gateway.metadata.name,
      namespace: gateway.metadata.namespace,
    }],
    hostnames: ['dependency-track.walnuts.dev'],
    rules: [
      {
        matches: [{ path: { type: 'PathPrefix', value: '/api' } }],
        backendRefs: [{ name: app.name + '-api-server', port: 8080 }],
      },
      {
        matches: [{ path: { type: 'PathPrefix', value: '/' } }],
        backendRefs: [{ name: app.name + '-frontend', port: 8080 }],
      },
    ],
  },
}
