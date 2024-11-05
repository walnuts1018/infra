(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: 'kibana',
    namespace: (import 'app.json5').namespace,
  },
  domain: 'kibana.walnuts.dev',
  upstream: 'http://kibana.elasticsearch.svc.cluster.local:5601',
  oidc:: {
    secret:: {
      onepassword_item_name: 'kibana-oauth2-proxy',
    },
    allowed_group: '237477822715658605:kibana-admin',
  },
}
