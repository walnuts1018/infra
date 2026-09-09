local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local service = import 'service.jsonnet';

local route(listener, port) = {
  apiVersion: 'gateway.networking.k8s.io/v1alpha2',
  kind: 'TCPRoute',
  metadata: {
    name: 'stalwart-' + listener,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
        sectionName: listener,
      },
    ],
    rules: [
      {
        backendRefs: [
          {
            name: service.metadata.name,
            port: port,
          },
        ],
      },
    ],
  },
};

{
  smtp: route('smtp', 25),
  smtps: route('smtps', 465),
  submission: route('submission', 587),
  imaps: route('imaps', 993),
}
