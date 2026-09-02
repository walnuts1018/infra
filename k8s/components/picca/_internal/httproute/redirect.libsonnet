function(app)
  local common = import 'common.libsonnet';
  local domain = app.name + '.walnuts.dev';
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-http',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [common.httpParentRef],
      hostnames: [
        domain,
      ],
      rules: [
        {
          filters: [
            {
              type: 'RequestRedirect',
              requestRedirect: {
                scheme: 'https',
                statusCode: 301,
              },
            },
          ],
        },
      ],
    },
  }
