function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-imgproxy',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'imgproxy_key',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-imgproxy-key',
        },
      },
      {
        secretKey: 'imgproxy_salt',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-imgproxy-salt',
        },
      },
    ],
    template_data: {
      IMGPROXY_PROMETHEUS_BIND: ':8081',
      IMGPROXY_FAIL_ON_DEPRECATION: 'true',
      IMGPROXY_USE_S3: 'true',
      IMGPROXY_S3_ENDPOINT: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
      IMGPROXY_S3_REGION: 'us-east-1',
      IMGPROXY_S3_ALLOWED_BUCKETS: app.name,
      IMGPROXY_S3_ENDPOINT_USE_PATH_STYLE: 'true',
      IMGPROXY_KEY: '{{ .imgproxy_key }}',
      IMGPROXY_SALT: '{{ .imgproxy_salt }}',
      IMGPROXY_ALLOW_ORIGIN: 'https://' + app.name + '.walnuts.dev',
      IMGPROXY_TTL: '900',
    },
  }
