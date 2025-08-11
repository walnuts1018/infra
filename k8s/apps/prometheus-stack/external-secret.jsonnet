(import '../../components/external-secret.libsonnet') {
  name: 'grafana',
  use_suffix: false,
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'grafana/admin-password',
      },
    },
    {
      secretKey: 'admin-username',
      remoteRef: {
        key: 'grafana/admin-username',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'grafana/client_secret',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords/grafana',
      },
    },
    {
      secretKey: 'smtp_password',
      remoteRef: {
        key: 'resend/api-key',
      },
    },
  ],
}
