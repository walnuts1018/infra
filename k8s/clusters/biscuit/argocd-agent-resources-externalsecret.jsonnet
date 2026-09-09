local cluster = import 'cluster.json5';
local clientCertificate = '{{ .clientCertificate | b64enc }}';
local clientKey = '{{ .clientKey | b64enc }}';
local caCertificate = '{{ .caCertificate | b64enc }}';
local resourcePayload = |||
  apiVersion: v1
  kind: Secret
  metadata:
    name: argocd-agent-client-tls
    namespace: argocd
  type: kubernetes.io/tls
  data:
    tls.crt: %s
    tls.key: %s
  ---
  apiVersion: v1
  kind: Secret
  metadata:
    name: argocd-agent-ca
    namespace: argocd
  type: Opaque
  data:
    ca.crt: %s
||| % [clientCertificate, clientKey, caCertificate];
{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'argocd-agent-resources',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '22',
    },
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      kind: 'ClusterSecretStore',
      name: 'argocd-agent-berry',
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
          key: 'argocd-agent-client-tls-biscuit',
          property: 'tls.crt',
        },
      },
      {
        secretKey: 'clientKey',
        remoteRef: {
          key: 'argocd-agent-client-tls-biscuit',
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
