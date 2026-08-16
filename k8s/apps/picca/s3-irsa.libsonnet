{
  env: [
    { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
    // seaweedfs.local.walnuts.devはenvoy-gateway経由でseaweedfs-default-filer:8333へ
    // ルーティングされるだけなので、cluster内DNSで直接同じバックエンドを指す
    // (envoy-gatewayのLoadBalancer IPが192.168.0.0/16でNetworkPolicyのegress
    // ipBlockから除外されているため、外部ドメイン経由だとSTSリクエストがブロックされる)。
    { name: 'AWS_ENDPOINT_URL_STS', value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333' },
    { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/picca' },
  ],
  volume: {
    name: 'seaweedfs-sts-token',
    projected: {
      sources: [
        {
          serviceAccountToken: {
            audience: 'sts.seaweedfs.com',
            expirationSeconds: 86400,
            path: 'token',
          },
        },
      ],
    },
  },
  volumeMount: {
    name: 'seaweedfs-sts-token',
    mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
    readOnly: true,
  },
}
