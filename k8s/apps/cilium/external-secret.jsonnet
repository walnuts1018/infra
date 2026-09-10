// Only kurumi's cilium runs ingressController (defaultSecretName:
// cloudflare-origin-cert); biscuit disables it and terminates TLS via its own
// cert-manager Certificate, so shipping the Cloudflare origin private key
// there too would needlessly widen its blast radius.
function(cluster='kurumi')
  if cluster == 'biscuit' then null else
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
