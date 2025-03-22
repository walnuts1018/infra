(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet')({
  app: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  domain: 'maple.walnuts.dev',
  upstream: 'http://maple.maple.svc.cluster.local:3000',
  oidc: {
    secret: {
      onepassword_item_name: 'maple-oauth2-proxy',
    },
    allowed_group: '237477822715658605:hubble-admin',
  },
})
