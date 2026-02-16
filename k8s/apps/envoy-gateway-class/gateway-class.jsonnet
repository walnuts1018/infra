function(loadBalancerIP, minReplicas) {
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
      name: (import 'envoy-proxy.jsonnet')(loadBalancerIP, minReplicas).metadata.name,
      namespace: (import 'envoy-proxy.jsonnet')(loadBalancerIP, minReplicas).metadata.namespace,
    },
  },
}
