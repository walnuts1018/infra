local app = import 'app.json5';
local service = import 'service.jsonnet';

{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'BackendTrafficPolicy',
  metadata: {
    name: 'stalwart-proxy-protocol',
    namespace: app.namespace,
  },
  spec: {
    targetRef: {
      group: '',
      kind: 'Service',
      name: service.metadata.name,
    },
    proxyProtocol: {
      version: 'V2',
    },
  },
}
