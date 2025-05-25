(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet')({
  app: {
    name: 'warrior',
    namespace: (import 'app.json5').namespace,
  },
  domain: 'warrior.walnuts.dev',
  upstream: 'http://warrior.warrior.svc.cluster.local:8001',
  oidc: {
    secret: {
      onepassword_item_name: 'warrior-oauth2-proxy',
    },
    allowed_group: '237477822715658605:warrior',
  },
})
