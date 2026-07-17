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
      communities:
        - targets:
            - 192.168.0.1
            - 192.168.4.2
            - 192.168.4.3
            - 192.168.4.4
          community: "{{ .snmp_community }}"
    |||,
  },
}
