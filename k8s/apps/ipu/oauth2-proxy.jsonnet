local domain = 'ipu.walnuts.dev';
(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet')(
  {
    app: {
      name: 'ipu',
      namespace: (import 'app.json5').namespace,
    },
    domain: domain,
    upstream: 'http://' + (import '../../utils/get-endpoint-from-service.libsonnet')(import './service.jsonnet') + ':8080',
    oidc: {
      secret: {
        onepassword_item_name: 'ipu-oauth2-proxy',
      },
      allowed_group: '326185042176901521:viewer',
    },
  },
)
