local labels = import '../../components/labels.libsonnet';
local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    parentRefs: [{ name: gateway.metadata.name, namespace: gateway.metadata.namespace }],
    hostnames: ['horse.walnuts.dev'],
    rules: [
      {
        matches: [{ path: { type: 'Exact', value: '/healthz' } }],
        timeouts: { request: '60s', backendRequest: '55s' },
        backendRefs: [{ kind: 'Service', name: app.name + '-api', port: 8080 }],
      },
      {
        matches: [{ path: { type: 'PathPrefix', value: '/graphql' } }],
        timeouts: { request: '0s', backendRequest: '0s' },
        backendRefs: [{ kind: 'Service', name: app.name + '-api', port: 8080 }],
      },
      {
        matches: [{ path: { type: 'PathPrefix', value: '/events' } }],
        timeouts: { request: '0s', backendRequest: '0s' },
        backendRefs: [{ kind: 'Service', name: app.name + '-api', port: 8080 }],
      },
      {
        matches: [
          { path: { type: 'PathPrefix', value: '/documents' } },
          { path: { type: 'PathPrefix', value: '/uploads' } },
        ],
        timeouts: { request: '5m', backendRequest: '4m' },
        backendRefs: [{ kind: 'Service', name: app.name + '-api', port: 8080 }],
      },
      {
        matches: [
          { path: { type: 'PathPrefix', value: '/auth' } },
          { path: { type: 'PathPrefix', value: '/purchases' } },
        ],
        timeouts: { request: '60s', backendRequest: '55s' },
        backendRefs: [{ kind: 'Service', name: app.name + '-api', port: 8080 }],
      },
      {
        matches: [{ path: { type: 'PathPrefix', value: '/' } }],
        backendRefs: [{ kind: 'Service', name: app.name + '-web', port: 3000 }],
      },
    ],
  },
}
