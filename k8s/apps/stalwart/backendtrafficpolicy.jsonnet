local app = import 'app.json5';
local routes = import 'tcproutes.jsonnet';

{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'BackendTrafficPolicy',
  metadata: {
    name: 'stalwart-proxy-protocol',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'TCPRoute',
        name: route.metadata.name,
      }
      for route in routes
    ],
    proxyProtocol: {
      version: 'V2',
    },
  },
}
