(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'diode_ingest_client_secret',
      remoteRef: {
        key: 'diode',
        property: 'diode_ingest_client_secret',
      },
    },
    {
      secretKey: 'snmp_community',
      remoteRef: {
        key: 'netbox_discovery',
        property: 'snmp_community',
      },
    },
  ],
  template_data: {
    DIODE_CLIENT_ID: 'diode-ingest',
    DIODE_CLIENT_SECRET: '{{ .diode_ingest_client_secret }}',
    SNMP_COMMUNITY: '{{ .snmp_community }}',
  },
}
