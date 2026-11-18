local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local adminCredentialFilter = import 'http-route-admin-filter.jsonnet';
local credentialFilter = import 'http-route-filter.jsonnet';
local server = import 'service-server.jsonnet';
local backendRule(contentType) = {
  matches: [{
    path: { type: 'PathPrefix', value: '/agr.v1.LearningAdminService/' },
    headers: [{ type: 'Exact', name: 'content-type', value: contentType }],
  }],
  timeouts: { request: '0s', backendRequest: '0s' },
  filters: [
    {
      type: 'RequestHeaderModifier',
      requestHeaderModifier: {
        set: [{ name: 'content-type', value: contentType }],
      },
    },
    {
      type: 'ExtensionRef',
      extensionRef: {
        group: 'gateway.envoyproxy.io',
        kind: 'HTTPRouteFilter',
        name: credentialFilter.metadata.name,
      },
    },
    {
      type: 'ExtensionRef',
      extensionRef: {
        group: 'gateway.envoyproxy.io',
        kind: 'HTTPRouteFilter',
        name: adminCredentialFilter.metadata.name,
      },
    },
  ],
  backendRefs: [{ kind: 'Service', name: server.metadata.name, port: 8080 }],
};
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-learning-admin',
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [{ name: gateway.metadata.name, namespace: gateway.metadata.namespace }],
    hostnames: ['agr.walnuts.dev'],
    rules: [
      backendRule('application/grpc-web+proto'),
      backendRule('application/grpc-web-text'),
    ],
  },
}
