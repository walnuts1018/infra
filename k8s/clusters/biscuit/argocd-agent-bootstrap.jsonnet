local cluster = import 'cluster.json5';
local namespace = cluster.namespace;
local selector = {
  matchLabels: {
    'argocd-agent.walnuts.dev/enabled': 'true',
  },
};
local spokeValues = importstr '../../_argocd/spoke/values.yaml';
local agentValues = importstr '../../_argocd/agent/agent/values.yaml';
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
[
  {
    apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
    kind: 'HelmChartProxy',
    metadata: {
      name: 'argocd-spoke',
      namespace: namespace,
    },
    spec: {
      clusterSelector: selector,
      chartName: 'argo-cd',
      repoURL: 'https://argoproj.github.io/argo-helm',
      version: '10.8.2',
      releaseName: 'argocd',
      namespace: 'argocd',
      reconcileStrategy: 'Continuous',
      options: {
        wait: true,
        install: { createNamespace: true },
      },
      valuesTemplate: spokeValues,
    },
  },
  {
    apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
    kind: 'HelmChartProxy',
    metadata: {
      name: 'argocd-agent',
      namespace: namespace,
    },
    spec: {
      clusterSelector: selector,
      chartName: 'argocd-agent-agent',
      repoURL: 'oci://ghcr.io/argoproj-labs/argocd-agent',
      version: '0.2.7',
      releaseName: 'argocd-agent',
      namespace: 'argocd',
      reconcileStrategy: 'Continuous',
      options: {
        wait: false,
        install: { createNamespace: true },
      },
      valuesTemplate: agentValues,
    },
  },
  {
    apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
    kind: 'ClusterResourceSet',
    metadata: {
      name: 'argocd-agent',
      namespace: namespace,
    },
    spec: {
      clusterSelector: selector,
      resources: [
        {
          kind: 'Secret',
          name: 'argocd-agent-resources',
        },
      ],
      strategy: 'Reconcile',
    },
  },
  {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'argocd-agent-secret-reader',
      namespace: 'argocd',
    },
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'argocd-agent-secret-reader',
      namespace: 'argocd',
    },
    rules: [
      {
        apiGroups: [''],
        resources: ['secrets'],
        resourceNames: ['argocd-agent-ca', 'argocd-agent-client-tls-biscuit'],
        verbs: ['get'],
      },
      {
        apiGroups: ['authorization.k8s.io'],
        resources: ['selfsubjectrulesreviews'],
        verbs: ['create'],
      },
    ],
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: 'argocd-agent-secret-reader',
      namespace: 'argocd',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'argocd-agent-secret-reader',
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: 'argocd-agent-secret-reader',
        namespace: 'argocd',
      },
    ],
  },
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ClusterSecretStore',
    metadata: {
      name: 'argocd-agent-berry',
    },
    spec: {
      conditions: [{ namespaces: [namespace] }],
      provider: {
        kubernetes: {
          remoteNamespace: 'argocd',
          server: {
            url: 'https://kubernetes.default.svc',
            caProvider: {
              type: 'ConfigMap',
              name: 'kube-root-ca.crt',
              namespace: 'argocd',
              key: 'ca.crt',
            },
          },
          auth: {
            serviceAccount: {
              name: 'argocd-agent-secret-reader',
              namespace: 'argocd',
            },
          },
        },
      },
    },
  },
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'argocd-agent-resources',
      namespace: namespace,
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
  },
]
