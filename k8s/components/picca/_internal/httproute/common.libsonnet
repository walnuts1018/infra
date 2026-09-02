{
  gateway: import '../../../../apps/envoy-gateway-class/gateway.jsonnet',

  responseHeadersFilter: {
    type: 'ResponseHeaderModifier',
    responseHeaderModifier: {
      set: [
        { name: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains' },
        { name: 'X-Content-Type-Options', value: 'nosniff' },
        { name: 'X-Frame-Options', value: 'DENY' },
        { name: 'Referrer-Policy', value: 'no-referrer' },
        {
          name: 'Permissions-Policy',
          value: 'camera=(), microphone=(), geolocation=(), payment=(), usb=(), serial=(), bluetooth=(), accelerometer=(), gyroscope=(), magnetometer=()',
        },
      ],
    },
  },

  httpsParentRef: {
    name: $.gateway.metadata.name,
    namespace: $.gateway.metadata.namespace,
    sectionName: 'https',
  },

  httpParentRef: {
    name: $.gateway.metadata.name,
    namespace: $.gateway.metadata.namespace,
    sectionName: 'http',
  },
}
