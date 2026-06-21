(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'diode_ingest_client_secret',
      remoteRef: {
        key: 'diode',
        property: 'diode-ingest-client-secret',
      },
    },
    {
      secretKey: 'snmp_community',
      remoteRef: {
        key: 'netbox_discovery',
        property: 'snmp_community',
      },
    },
    {
      secretKey: 'napalm_username',
      remoteRef: {
        key: 'netbox_discovery',
        property: 'napalm_username',
      },
    },
    {
      secretKey: 'napalm_password',
      remoteRef: {
        key: 'netbox_discovery',
        property: 'napalm_password',
      },
    },
    // {
    //   secretKey: 'napalm_enable_password',
    //   remoteRef: {
    //     key: 'netbox_discovery',
    //     property: 'napalm_enable_password',
    //   },
    // },
  ],
  template_data: {
    DIODE_CLIENT_ID: 'diode-ingest',
    DIODE_CLIENT_SECRET: '{{ .diode_ingest_client_secret }}',
    SNMP_COMMUNITY: '{{ .snmp_community }}',
    NAPALM_USERNAME: '{{ .napalm_username }}',
    NAPALM_PASSWORD: '{{ .napalm_password }}',
    // NAPALM_ENABLE_PASSWORD: '{{ .napalm_enable_password }}',
  },
}
