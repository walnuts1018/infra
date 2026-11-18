local app = import 'app.json5';
local adminCredential = import 'external-secret-learning-admin.jsonnet';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'HTTPRouteFilter',
  metadata: {
    name: app.name + '-learning-admin-credential',
    namespace: app.namespace,
  },
  spec: {
    credentialInjection: {
      header: 'x-learning-admin-gateway-token',
      overwrite: true,
      credential: {
        valueRef: {
          name: adminCredential.spec.target.name,
        },
      },
    },
  },
}
