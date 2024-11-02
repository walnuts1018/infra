(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: "longhorn"
    namespace: (import 'app.json5').namespace,
  },
  domain: 'longhorn.walnuts.dev',
  upstream: "http://longhorn-frontend.longhorn-system.svc.cluster.local/#/dashboard",
  oidc:: {
    secret:: {
      onepassword_item_name: 'longhorn-oauth2-proxy',
    },
    allowed_group: "237477822715658605:longhorn-admin",
  },
}
