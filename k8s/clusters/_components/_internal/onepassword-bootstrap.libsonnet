local resourcePayloadTemplate = importstr 'onepassword-resources.yaml.tmpl';
local credentials = '{{ .credentials | b64enc }}';
local token = '{{ .token | b64enc }}';
local resourcePayload = resourcePayloadTemplate % [credentials, token];

{
  externalSecret(cluster):: {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'onepassword-bootstrap',
      namespace: cluster.namespace,
    },
    spec: {
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'ClusterSecretStore',
        name: 'onepassword',
      },
      target: {
        name: 'onepassword-bootstrap',
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
          secretKey: 'credentials',
          remoteRef: {
            key: 'k8s Credentials File',
            property: 'file/1password-credentials.json',
          },
        },
        {
          secretKey: 'token',
          remoteRef: {
            key: 'pcookjymtl2zwyozhofaco5yhy',
            property: 'credential',
          },
        },
      ],
    },
  },

  clusterResourceSet(cluster):: {
    apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
    kind: 'ClusterResourceSet',
    metadata: {
      name: 'onepassword-bootstrap',
      namespace: cluster.namespace,
    },
    spec: {
      clusterSelector: {
        matchLabels: {
          'argocd-agent.walnuts.dev/enabled': 'true',
          'cluster.x-k8s.io/cluster-name': cluster.name,
        },
      },
      resources: [
        {
          kind: 'Secret',
          name: 'onepassword-bootstrap',
        },
      ],
      strategy: 'Reconcile',
    },
  },
}
