{
  tenant: {
    name: 'biscuit',
    pools: [
      {
        name: 'pool-0',
        resources: {
          requests: {
            cpu: '100m',
            memory: '1Gi',
          },
          limits: {
            cpu: '1',
            memory: '4Gi',
          },
        },
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        servers: 1,
        size: '32Gi',
        storageClassName: (import 'persistent-volume.jsonnet').spec.storageClassName,
        volumesPerServer: 1,
      },
    ],
    certificate: {
      requestAutoCert: false,
    },
    local region = 'ap-northeast-1',
    buckets: [
      { name: bucket_name, region: region }
      for bucket_name in (import 'buckets.json5')
    ],
    configSecret: {
      name: (import 'storage-configuration.jsonnet').spec.target.name,
      existingSecret: true,
    },
    env: [
      {
        name: 'MINIO_SERVER_URL',
        value: 'https://minio-biscuit.local.walnuts.dev',
      },
      {
        name: 'MINIO_BROWSER_REDIRECT_URL',
        value: 'https://minio-biscuit-console.local.walnuts.dev',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_CONFIG_URL',
        value: 'https://auth.walnuts.dev/.well-known/openid-configuration',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_CLIENT_ID',
        value: '340410953382297837',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_CLAIM_NAME',
        value: 'minio-policy',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_SCOPES',
        value: 'openid,profile,email',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_REDIRECT_URI',
        value: 'https://minio-biscuit-console.local.walnuts.dev/oauth_callback',
      },
      {
        name: 'MINIO_IDENTITY_OPENID_DISPLAY_NAME',
        value: 'Walnuts.dev',
      },
    ],
    features: {
      bucketDNS: true,
      domains: {
        console: 'minio-biscuit-console.local.walnuts.dev',
        minio: [
          'minio-biscuit.local.walnuts.dev',
        ],
      },
    },
    metrics: {
      enabled: true,
      port: 9000,
      protocol: 'http',
    },
    users: [],
  },

  ingress: {
    api: {
      enabled: true,
      host: 'minio-biscuit.local.walnuts.dev',
      ingressClassName: 'cilium',
      path: '/',
      pathType: 'Prefix',
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
      },
      tls: [
        {
          hosts: [
            'minio-biscuit.local.walnuts.dev',
          ],
          secretName: 'minio-biscuit-tls',
        },
      ],
    },
    console: {
      enabled: true,
      host: 'minio-biscuit-console.local.walnuts.dev',
      ingressClassName: 'cilium',
      path: '/',
      pathType: 'Prefix',
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
      },
      tls: [
        {
          hosts: [
            'minio-biscuit-console.local.walnuts.dev',
          ],
          secretName: 'minio-biscuit-console-tls',
        },
      ],
    },
  },
}
