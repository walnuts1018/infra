local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local credentialFilter = import 'http-route-filter.jsonnet';
local server = import 'service-server.jsonnet';
local web = import 'service-web.jsonnet';
local backendRule(contentType) = {
  matches: [{
    headers: [{ type: 'Exact', name: 'content-type', value: contentType }],
  }],
  timeouts: { request: '0s', backendRequest: '0s' },
  filters: [{
    type: 'ExtensionRef',
    extensionRef: {
      group: 'gateway.envoyproxy.io',
      kind: 'HTTPRouteFilter',
      name: credentialFilter.metadata.name,
    },
  }],
  backendRefs: [{ kind: 'Service', name: server.metadata.name, port: 8080 }],
};
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [{ name: gateway.metadata.name, namespace: gateway.metadata.namespace }],
    hostnames: ['agr.walnuts.dev'],
    rules: [
      backendRule('application/grpc-web+proto'),
      backendRule('application/grpc-web-text'),
      {
        matches: [{ path: { type: 'PathPrefix', value: '/' } }],
        backendRefs: [{ kind: 'Service', name: web.metadata.name, port: 3000 }],
      },
    ],
  },
}
