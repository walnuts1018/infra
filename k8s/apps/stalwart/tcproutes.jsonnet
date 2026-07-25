local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local service = import 'service.jsonnet';
local routes = [
  { listener: 'smtp', port: 25 },
  { listener: 'smtps', port: 465 },
  { listener: 'submission', port: 587 },
  { listener: 'imaps', port: 993 },
];
[
  {
    apiVersion: 'gateway.networking.k8s.io/v1alpha2',
    kind: 'TCPRoute',
    metadata: {
      name: 'stalwart-' + route.listener,
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [
        {
          name: gateway.metadata.name,
          namespace: gateway.metadata.namespace,
          sectionName: route.listener,
        },
      ],
      rules: [
        {
          backendRefs: [
            {
              name: service.metadata.name,
              port: route.port,
            },
          ],
        },
      ],
    },
  }
  for route in routes
]
