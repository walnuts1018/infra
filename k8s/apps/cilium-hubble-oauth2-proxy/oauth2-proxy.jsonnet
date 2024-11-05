(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  domain: 'hubble.walnuts.dev',
  upstream: 'http://hubble-ui.cilium-system.svc.cluster.local:80',
  oidc:: {
    secret:: {
      onepassword_item_name: 'hubble-oauth2-proxy',
    },
    allowed_group: '237477822715658605:hubble-admin',
  },
}
