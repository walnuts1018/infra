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
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: ['penpot.walnuts.dev'],
    rules: [
      {
        timeouts: {
          request: '0s',
          backendRequest: '0s',
        },
        backendRefs: [
          {
            name: app.name,
            port: 8080,
          },
        ],
      },
    ],
  },
}
