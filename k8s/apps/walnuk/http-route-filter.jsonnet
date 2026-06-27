{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'HTTPRouteFilter',
  metadata: {
    name: 'admin-auth-filter',
    namespace: (import 'app.json5').namespace,
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
