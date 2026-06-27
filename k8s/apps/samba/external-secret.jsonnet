local externalSecret = import '../../components/external-secret.libsonnet';
(externalSecret) {
  name: 'samba-secret',
  data: [
    {
      secretKey: 'account-samba',
      remoteRef: {
        key: 'samba',
        property: 'password',
      },
    },
  ],
}
