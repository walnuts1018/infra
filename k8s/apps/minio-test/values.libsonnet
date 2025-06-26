{
  tenant: {
    name: 'test',
    configSecret: {
      name: (import 'storage-configuration.jsonnet').spec.target.name,
      existingSecret: true,
    },
    certificate: {
      requestAutoCert: false,
    },
    pools: [
      {
        servers: 4,
        name: 'pool',
        volumesPerServer: 4,
        size: '10Gi',
        resources: {},
        metrics: {
          enabled: true,
          port: 9000,
          protocol: 'http',
        },
        features: {
          bucketDNS: true,
          domains: {
            minio: [
              'minio-test.walnuts.dev',
            ],
            console: 'minio-test-console.walnuts.dev',
          },
        },
        buckets: [],
        users: [],
        prometheusOperator: true,
        env: [],
      },
    ],
  },
  ingress: {
    api: {
      enabled: true,
      ingressClassName: 'cilium',
      host: 'minio-test.walnuts.dev',
      path: '/',
      pathType: 'Prefix',
    },
    console: {
      enabled: true,
      ingressClassName: 'cilium',
      host: 'minio-test-console.walnuts.dev',
      path: '/',
      pathType: 'Prefix',
    },
  },
}
