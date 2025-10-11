{
  name:: error 'name is required',
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'EnvoyPatchPolicy',
  metadata: {
    name: $.name + '-oidc-patch',
    namespace: (import '../../apps/envoy-gateway-class/gateway.jsonnet').metadata.namespace,
  },
  spec: {
    targetRef: {
      group: 'gateway.networking.k8s.io',
      kind: 'Gateway',
      name: (import '../../apps/envoy-gateway-class/gateway.jsonnet').metadata.name,
    },
    type: 'JSONPatch',
    jsonPatches: [
      {
        type: 'type.googleapis.com/envoy.config.listener.v3.Listener',
        name: 'envoy-gateway-system/envoy-gateway/http',
        operation: {
          op: 'add',
          jsonPath: "..default_filter_chain.filters[0].typed_config.http_filters[?match(@.name, 'envoy.filters.http.oauth2/securitypolicy/.*%s')].typed_config.config" % (import './security-policy-suffix.libsonnet'),
          path: 'forward_bearer_token',
          value: true,
        },
      },
      {
        type: 'type.googleapis.com/envoy.config.listener.v3.Listener',
        name: 'envoy-gateway-system/envoy-gateway/http',
        operation: {
          op: 'add',
          jsonPath: "..default_filter_chain.filters[0].typed_config.http_filters[?match(@.name, 'envoy.filters.http.oauth2/securitypolicy/.*%s')].typed_config.config" % (import './security-policy-suffix.libsonnet'),
          path: 'preserve_authorization_header',
          value: false,
        },
      },
    ],
  },
}
