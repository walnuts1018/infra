(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet')({
  app: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  domain: 'openclarity.walnuts.dev',
  upstream: 'http://prometheus-operated.monitoring.svc.cluster.local:9090',
  oidc: {
    secret: {
      onepassword_item_name: 'openclarity-oauth2-proxy',
    },
    allowed_group: '237477822715658605:openclarity-admin',
  },
})
