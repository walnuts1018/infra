local app = import 'app.json5';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'HTTPRouteFilter',
  metadata: {
    name: 'admin-auth-filter',
    namespace: app.namespace,
  },
  spec: {
    directResponse: {
      contentType: 'text/plain',
      statusCode: 401,
      body: {
        type: 'Inline',
        inline: 'Unauthorized',
      },
    },
  },
}
