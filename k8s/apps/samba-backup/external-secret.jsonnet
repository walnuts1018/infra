(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'id_ed25519',
      remoteRef: {
        key: 'samba-backup/private_key',
      },
    },
    {
      secretKey: 'user',
      remoteRef: {
        key: 'samba-backup/user',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'samba-backup/password',
      },
    },
  ],
}
