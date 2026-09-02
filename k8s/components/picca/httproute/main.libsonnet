function(app)
  local common = import 'common.libsonnet';
  local frontendServiceName = app.name + '-frontend';
  local apiserverServiceName = app.name + '-apiserver';
  local domain = app.name + '.walnuts.dev';
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name,
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [common.httpsParentRef],
      hostnames: [
        domain,
      ],
      rules: [
        {
          matches: [
            {
              path: {
                type: 'PathPrefix',
                value: '/api/health',
              },
            },
            {
              path: {
                type: 'PathPrefix',
                value: '/api/telemetry',
              },
            },
          ],
          filters: [common.responseHeadersFilter],
          backendRefs: [
            { kind: 'Service', name: frontendServiceName, port: 3000, weight: 1 },
          ],
        },
        {
          matches: [
            {
              path: {
                type: 'PathPrefix',
                value: '/auth',
              },
            },
            {
              path: {
                type: 'PathPrefix',
                value: '/query',
              },
            },
            {
              path: {
                type: 'PathPrefix',
                value: '/api',
              },
            },
          ],
          filters: [common.responseHeadersFilter],
          timeouts: {
            request: '0s',
            backendRequest: '0s',
          },
          backendRefs: [
            { kind: 'Service', name: apiserverServiceName, port: 8080, weight: 1 },
          ],
        },
        {
          filters: [common.responseHeadersFilter],
          backendRefs: [
            { kind: 'Service', name: frontendServiceName, port: 3000, weight: 1 },
          ],
        },
      ],
    },
  }
