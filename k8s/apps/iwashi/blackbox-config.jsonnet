local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: { name: app.name + '-blackbox', namespace: app.namespace },
  data: {
    'blackbox.yaml': |||
      modules:
        http:
          prober: http
          timeout: 10s
          http:
            preferred_ip_protocol: ip4
            follow_redirects: true
            enable_http2: true
    |||,
  },
}
