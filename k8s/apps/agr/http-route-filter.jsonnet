local app = import 'app.json5';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'HTTPRouteFilter',
  metadata: {
    name: app.name + '-gateway-credential',
    namespace: app.namespace,
  },
  spec: {
    credentialInjection: {
      header: 'x-gateway-token',
      overwrite: true,
      credential: {
        valueRef: {
          name: (import 'external-secret-gateway-credential.jsonnet').spec.target.name,
        },
      },
    },
  },
}
