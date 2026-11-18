local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local adminCredentialFilter = import 'http-route-admin-filter.jsonnet';
local server = import 'service-server.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'GRPCRoute',
  metadata: {
    name: app.name + '-learning-admin',
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [{ name: gateway.metadata.name, namespace: gateway.metadata.namespace }],
    hostnames: ['agr.walnuts.dev'],
    rules: [{
      matches: [
        { method: { service: 'agr.v1.LearningAdminService', method: 'GetDashboard' } },
        { method: { service: 'agr.v1.LearningAdminService', method: 'ExecuteAction' } },
        { method: { service: 'agr.v1.LearningAdminService', method: 'UpdateSettings' } },
      ],
      filters: [{
        type: 'ExtensionRef',
        extensionRef: {
          group: 'gateway.envoyproxy.io',
          kind: 'HTTPRouteFilter',
          name: adminCredentialFilter.metadata.name,
        },
      }],
      backendRefs: [{ kind: 'Service', name: server.metadata.name, port: 8080 }],
    }],
  },
}
