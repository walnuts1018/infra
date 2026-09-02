function(app) [
  {
    name: 'AWS_ENDPOINT_URL_S3',
    value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
  },
  {
    name: 'AWS_REGION',
    value: 'us-east-1',
  },
  {
    name: 'S3_REGION',
    value: 'us-east-1',
  },
  {
    name: 'S3_BUCKET',
    value: app.name,
  },
  {
    name: 'S3_USE_PATH_STYLE',
    value: 'true',
  },
  {
    name: 'S3_EXTERNAL_ENDPOINT',
    value: 'https://' + app.name + '.seaweedfs.walnuts.dev',
  },
  {
    name: 'IMGPROXY_PUBLIC_URL',
    value: 'https://imgproxy-' + app.name + '.walnuts.dev',
  },
  {
    name: 'IMGPROXY_BUCKET',
    value: app.name,
  },
  {
    name: 'IMGPROXY_TTL',
    value: '900',
  },
]
