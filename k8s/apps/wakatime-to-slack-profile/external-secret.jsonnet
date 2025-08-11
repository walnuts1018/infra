(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'cookie-secret',
      remoteRef: {
        key: 'wakatime-to-slack-profile/cookie-secret',
      },
    },
    {
      secretKey: 'postgres-password',
      remoteRef: {
        key: 'postgres_passwords/wakatime',
      },
    },
    {
      secretKey: 'slack-access-token',
      remoteRef: {
        key: 'wakatime-to-slack-profile/slack-access-token',
      },
    },
    {
      secretKey: 'wakatime-app-id',
      remoteRef: {
        key: 'wakatime-to-slack-profile/wakatime-app-id',
      },
    },
    {
      secretKey: 'wakatime-client-secret',
      remoteRef: {
        key: 'wakatime-to-slack-profile/wakatime-client-secret',
      },
    },
  ],
}
