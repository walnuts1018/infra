// gateway-api-crdsは、このbootstrapが入れるCNIに依存するので先には流れない。CRDが存在しない
// 段階でgatewayAPIを有効にしたままだとcilium-operatorが起動に失敗するため、この一回限りの
// InstallOnceではgatewayAPIを強制的に無効化する。CRD導入後はArgo CD Agent経由の通常Applicationが
// 元のvalues(gatewayAPI.enabled)で上書きする。
function(cluster, baseValues, version='1.20.1') {
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'cilium-bootstrap',
    namespace: cluster.namespace,
    annotations: {
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
        'cluster.x-k8s.io/cluster-name': cluster.name,
      },
    },
    chartName: 'cilium',
    repoURL: 'https://helm.cilium.io/',
    version: version,
    releaseName: 'cilium',
    namespace: 'cilium-system',
    reconcileStrategy: 'InstallOnce',
    options: {
      wait: true,
      install: { createNamespace: true },
    },
    // baseValues is the same merged base/cluster override used by the
    // steady-state Application. Only the bootstrap-only gateway override is
    // applied here.
    valuesTemplate: std.manifestYamlDoc(std.mergePatch(baseValues, {
      gatewayAPI: { enabled: false },
    })),
  },
}
