// The Cloudflare origin secret is enabled only for the Cilium deployment whose
// ingressController consumes cloudflare-origin-cert. Other deployments use
// their own certificate source and must not receive this private key.
function(cloudflareOriginCert='false')
  if cloudflareOriginCert != 'true' then null else
    std.mergePatch((import '../../components/external-secret.libsonnet') {
      name: 'cloudflare-origin-cert',
      namespace: (import 'app.json5').namespace,
      use_suffix: false,
      data: [
        {
          secretKey: 'tls.crt',
          remoteRef: {
            key: 'cloudflare-origin-cert',
            property: 'tls.crt',
          },
        },
        {
          secretKey: 'tls.key',
          remoteRef: {
            key: 'cloudflare-origin-cert',
            property: 'tls.key',
          },
        },
      ],
    }, {
      spec: {
        target: {
          template: {
            type: 'kubernetes.io/tls',
          },
        },
      },
    })
