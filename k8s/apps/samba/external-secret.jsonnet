(import '../../components/external-secret.libsonnet') {
  name: 'samba-secret',
  data: [
    {
      secretKey: 'account-samba',
      remoteRef: {
        key: 'samba/password',
      },
    },
  ],
}
