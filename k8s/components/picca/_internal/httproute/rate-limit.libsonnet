function(app)
  local clientIP = function(cidr, path) {
    clientSelectors: [
      {
        sourceCIDR: {
          type: 'Distinct',
          value: cidr,
        },
        path: {
          type: 'PathPrefix',
          value: path,
        },
      },
    ],
  };
  local rule = function(path, requests) [
    clientIP(cidr, path) + {
      limit: {
        requests: requests,
        unit: 'Second',
      },
    }
    for cidr in ['0.0.0.0/0', '::/0']
  ];
  {
    apiVersion: 'gateway.envoyproxy.io/v1alpha1',
    kind: 'BackendTrafficPolicy',
    metadata: {
      name: app.name + '-rate-limit',
      namespace: app.namespace,
    },
    spec: {
      targetRefs: [
        {
          group: 'gateway.networking.k8s.io',
          kind: 'HTTPRoute',
          name: app.name,
        },
      ],
      rateLimit: {
        global: {
          rules: rule('/auth', 2) + rule('/query', 20),
        },
      },
    },
  }
