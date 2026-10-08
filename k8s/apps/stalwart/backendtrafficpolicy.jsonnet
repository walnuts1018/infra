local app = import 'app.json5';
local httpRoute = import 'httproute.jsonnet';
local routes = import 'tcproutes.libsonnet';

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
        name: routes.smtp.metadata.name,
      },
      {
        group: 'gateway.networking.k8s.io',
        kind: 'TCPRoute',
        name: routes.smtps.metadata.name,
      },
      {
        group: 'gateway.networking.k8s.io',
        kind: 'TCPRoute',
        name: routes.submission.metadata.name,
      },
      {
        group: 'gateway.networking.k8s.io',
        kind: 'TCPRoute',
        name: routes.imaps.metadata.name,
      },
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        name: httpRoute.metadata.name,
      },
    ],
    proxyProtocol: {
      version: 'V2',
    },
  },
}
