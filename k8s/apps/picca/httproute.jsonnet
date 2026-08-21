local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';

local commonResponseHeaders = [
  { name: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains' },
  { name: 'X-Content-Type-Options', value: 'nosniff' },
  { name: 'X-Frame-Options', value: 'DENY' },
  { name: 'Referrer-Policy', value: 'no-referrer' },
  {
    name: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=(), payment=(), usb=(), serial=(), bluetooth=(), accelerometer=(), gyroscope=(), magnetometer=()',
  },
];

local responseHeadersFilter = {
  type: 'ResponseHeaderModifier',
  responseHeaderModifier: {
    set: commonResponseHeaders,
  },
};

local httpsParentRef = {
  name: gateway.metadata.name,
  namespace: gateway.metadata.namespace,
  sectionName: 'https',
};

local httpParentRef = {
  name: gateway.metadata.name,
  namespace: gateway.metadata.namespace,
  sectionName: 'http',
};

[
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name,
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [httpsParentRef],
      hostnames: [
        'picca.walnuts.dev',
      ],
      rules: [
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
                value: '/api/media',
              },
            },
          ],
          filters: [responseHeadersFilter],
          timeouts: {
            request: '0s',
            backendRequest: '0s',
          },
          backendRefs: [
            { kind: 'Service', name: (import 'apiserver/service.jsonnet').metadata.name, port: 8080, weight: 1 },
          ],
        },
        {
          filters: [responseHeadersFilter],
          backendRefs: [
            { kind: 'Service', name: (import 'frontend/service.jsonnet').metadata.name, port: 3000, weight: 1 },
          ],
        },
      ],
    },
  },
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-http',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [httpParentRef],
      hostnames: [
        'picca.walnuts.dev',
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
  },
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-imgproxy',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [httpsParentRef],
      hostnames: [
        'imgproxy-picca.walnuts.dev',
      ],
      rules: [
        {
          backendRefs: [
            {
              kind: 'Service',
              name: (import 'imgproxy/service.jsonnet').metadata.name,
              port: 80,
              weight: 1,
            },
          ],
        },
      ],
    },
  },
]
