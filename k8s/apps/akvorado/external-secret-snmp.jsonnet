local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: 'akvorado-snmp',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'snmp_community',
      remoteRef: {
        key: 'snmp',
        property: 'community',
      },
    },
  ],
  template_data: {
    'snmp.yaml': |||
      - type: snmp
        credentials:
          ::/0:
            communities:
              - "{{ .snmp_community }}"
    |||,
  },
}
