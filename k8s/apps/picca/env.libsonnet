// apiserver / migrations / thumbnailer系ワーカーで共通の非機密環境変数
[
  { name: 'ENVIRONMENT', value: 'production' },
  // S3(SeaweedFS)への認証情報はAWS SDK標準クレデンシャルチェーン(AssumeRoleWithWebIdentity)に委ねる。
  // AWS_ROLE_ARN/AWS_WEB_IDENTITY_TOKEN_FILE/AWS_ENDPOINT_URL_STSは各Deployment側で
  // ServiceAccountトークンのvolume mountとあわせて設定する。
  { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333' },
  { name: 'AWS_REGION', value: 'us-east-1' },
  { name: 'S3_REGION', value: 'us-east-1' },
  { name: 'S3_BUCKET', value: 'picca' },
  { name: 'S3_USE_PATH_STYLE', value: 'true' },
  // presigned URL(ダウンロード/アップロード)をクライアントが直接叩けるよう、
  // seaweedfs-default/s3-gateway-httproute.jsonnet で公開しているホスト名を指定する。
  { name: 'S3_EXTERNAL_ENDPOINT', value: 'https://picca.seaweedfs.walnuts.dev' },
  // SCYLLA_HOSTSは[]string(env区切りはカンマ)で、gocql.NewCluster(cfg.Hosts...)にそのまま渡される。
  // gocqlはhost:port形式を解釈するため、TLSリスナーのポート9142を明示的に含める。
  { name: 'SCYLLA_HOSTS', value: 'scylla-cluster-client.databases.svc.cluster.local:9142' },
  { name: 'SCYLLA_DATACENTER', value: 'iwakura' },
  { name: 'SCYLLA_USER', value: 'picca' },
  { name: 'OIDC_ISSUER', value: 'https://auth.walnuts.dev' },
  { name: 'OIDC_AUTH_URL', value: 'https://auth.walnuts.dev/oauth/v2/authorize' },
  { name: 'OIDC_REDIRECT_URL', value: 'https://picca.walnuts.dev/auth/callback' },
  { name: 'PUBLIC_API_URL', value: 'https://picca.walnuts.dev' },
  { name: 'ALLOWED_ORIGIN', value: 'https://picca.walnuts.dev' },
  { name: 'GRAPHQL_QUERY_SIGNING_REQUIRED', value: 'true' },
  { name: 'IMGPROXY_PUBLIC_URL', value: 'https://imgproxy-picca.walnuts.dev' },
  { name: 'IMGPROXY_BUCKET', value: 'picca' },
  { name: 'IMGPROXY_TTL', value: '900' },
  { name: 'OTEL_EXPORTER_OTLP_ENDPOINT', value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318' },
]
