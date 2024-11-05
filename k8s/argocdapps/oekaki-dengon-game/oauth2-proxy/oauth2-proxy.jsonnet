(import '../../../components/oauth2-proxy/oauth2-proxy.libsonnet') {
  app:: {
    name: 'oekaki',
    namespace: (import '../app.json5').namespace,
  },
  domain: 'oekaki.walnuts.dev',
  upstream: 'http://oekaki-dengon-game-front.oekaki-dengon-game.svc.cluster.local:3000/',
  oidc:: {
    secret:: {
      onepassword_item_name: 'oekaki-oauth2-proxy',
    },
    allowed_group: '237477822715658605:oekaki-admin',
  },
  valuesObject:: {
    config: {
      configFile: 'email_domains = [ "*" ]\nupstreams = [ "%s" ]\npass_access_token = true\nuser_id_claim = "sub"\noidc_groups_claim="my:zitadel:grants"\nallowed_groups = ["%s"]\nskip_auth_routes = ["/public","GET=/api","/_next", "/texture.png", "/favicon.ico", "site.webmanifest"]\ncustom_templates_dir = "/etc/oauth2-proxy/templates"' % [$.upstream, $.oidc.allowed_group],
    },
    extraVolumes: [
      {
        name: 'custom-templates',
        configMap: {
          name: (import 'configmap.jsonnet').metadata.name,
          items: [
            {
              key: 'robots.txt',
              path: 'robots.txt',
            },
          ],
        },
      },
    ],
    extraVolumeMounts: [
      {
        name: 'custom-templates',
        mountPath: '/etc/oauth2-proxy/templates',
        readOnly: true,
      },
    ],
  },
}
