local domain = 'static.walnuts.dev';
(import '../../components/oauth2-proxy/oauth2-proxy.libsonnet')(
  {
    app: {
      name: 'static-private',
      namespace: (import 'app.json5').namespace,
    },
    domain: domain,
    upstream: 'http://' + (import '../../utils/get-endpoint-from-service.libsonnet')(import './service.jsonnet') + ':8080',
    oidc: {
      secret: {
        onepassword_item_name: 'static-private-oauth2-proxy',
      },
      allowed_group: '326185042176901521:viewer',
    },
  },
  valuesObject={
    ingress: {
      enabled: true,
      className: 'cilium',
      path: '/private',
      pathType: 'Prefix',
      hosts: [
        domain,
      ],
      extraPaths: [
        {
          path: '/',
          pathType: 'Prefix',
          backend: {
            service: {
              name: (import 'service.jsonnet').metadata.name,
              port: {
                number: (import 'service.jsonnet').spec.ports[0].port,
              },
            },
          },
        },
      ],
    },
  }
)
