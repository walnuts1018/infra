(import '../../components/external-secret.libsonnet') {
  name: 'samba-secret',
  data: [
    {
      secretKey: 'account-samba',
      remoteRef: {
        key: 'samba',
        property: 'password',
      },
    },
    {
      secretKey: 'monitor-username',
      remoteRef: {
        key: 'samba',
        property: 'monitor-username',
      },
    },
    {
      secretKey: 'monitor-password',
      remoteRef: {
        key: 'samba',
        property: 'monitor-password',
      },
    },
  ],
}
