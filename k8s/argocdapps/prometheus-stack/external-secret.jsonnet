(import '../../components/external-secret.libsonnet') {
  name: 'grafana',
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'grafana',
        property: 'admin-password',
      },
    },
    {
      secretKey: 'admin-username',
      remoteRef: {
        key: 'grafana',
        property: 'admin-username',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'grafana',
        property: 'client_secret',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'grafana',
      },
    },
    {
      secretKey: 'smtp_password',
      remoteRef: {
        key: 'gmail',
        property: 'password',
      },
    },
  ],
}
