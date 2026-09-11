local resourcePayloadTemplate = importstr 'argocd-agent-resources.yaml.tmpl';
local clientCertificate = '{{ .clientCertificate | b64enc }}';
local clientKey = '{{ .clientKey | b64enc }}';
local caCertificate = '{{ .caCertificate | b64enc }}';
local resourcePayload = resourcePayloadTemplate % [clientCertificate, clientKey, caCertificate];
function(cluster) {
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'argocd-agent-resources',
    namespace: cluster.namespace,
    annotations: {
    },
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      kind: 'ClusterSecretStore',
      name: 'argocd-agent-' + cluster.name,
    },
    target: {
      name: 'argocd-agent-resources',
      creationPolicy: 'Owner',
      template: {
        engineVersion: 'v2',
        type: 'addons.cluster.x-k8s.io/resource-set',
        data: {
          'resources.yaml': resourcePayload,
        },
      },
    },
    data: [
      {
        secretKey: 'clientCertificate',
        remoteRef: {
          key: 'argocd-agent-client-tls-' + cluster.name,
          property: 'tls.crt',
        },
      },
      {
        secretKey: 'clientKey',
        remoteRef: {
          key: 'argocd-agent-client-tls-' + cluster.name,
          property: 'tls.key',
        },
      },
      {
        secretKey: 'caCertificate',
        remoteRef: {
          key: 'argocd-agent-ca',
          property: 'tls.crt',
        },
      },
    ],
  },
}
