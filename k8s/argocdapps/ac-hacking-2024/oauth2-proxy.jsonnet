(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: 'ac-hacking',
    namespace: (import 'app.json5').namespace,
  },
  domain: 'ac-hacking-2024.walnuts.dev',
  upstream: 'http://ac-hacking-2024-back.ac-hacking-2024.svc.cluster.local:8080',
  oidc:: {
    secret:: {
      onepassword_item_name: 'ac-hacking-oauth2-proxy',
    },
    allowed_group: '237477822715658605:ac-hacking-admin',
  },
}
