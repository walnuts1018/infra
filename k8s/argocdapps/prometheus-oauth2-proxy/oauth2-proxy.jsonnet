(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: 'prometheus',
    namespace: (import 'app.json5').namespace,
  },
  domain: 'prometheus.walnuts.dev',
  upstream: 'http://prometheus-operated.monitoring.svc.cluster.local:9090',
  oidc:: {
    secret:: {
      onepassword_item_name: 'prometheus-oauth2-proxy',
    },
    allowed_group: '237477822715658605:prometheus-admin',
  },
}
