local envoyProxy = import 'envoy-proxy.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'GatewayClass',
  metadata: {
    name: 'envoy-gateway',
  },
  spec: {
    controllerName: 'gateway.envoyproxy.io/gatewayclass-controller',
    parametersRef: {
      group: 'gateway.envoyproxy.io',
      kind: 'EnvoyProxy',
      name: (envoyProxy)().metadata.name,
      namespace: (envoyProxy)().metadata.namespace,
    },
  },
}
