local cluster = import 'cluster.json5';
local baseValues = std.parseYaml(importstr '../../apps/cilium/values.biscuit.yaml');
{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'cilium-bootstrap',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '20',
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
      },
    },
    chartName: 'cilium',
    repoURL: 'https://helm.cilium.io/',
    version: '1.20.1',
    releaseName: 'cilium',
    namespace: 'cilium-system',
    reconcileStrategy: 'InstallOnce',
    options: {
      wait: true,
      install: { createNamespace: true },
    },
    // Gateway API CRDs are installed by the ordinary gateway-api-crds
    // Application (k8s/apps/gateway-api-crds), which needs the CNI this
    // bootstrap installs and so cannot run first. Disable gatewayAPI for
    // this one-shot install to avoid depending on CRDs that don't exist
    // yet; the cilium Application that takes over afterwards re-enables it
    // via values.biscuit.yaml. If gateway-api-crds hasn't synced by the
    // time cilium-operator first starts with gatewayAPI enabled, it simply
    // skips the Gateway controllers until the operator is next restarted
    // (e.g. on a future Cilium upgrade) -- not required for basic CNI
    // function. std.mergePatch avoids emitting a duplicate top-level
    // `gatewayAPI` key, whose resolution order is undefined for the YAML
    // parser CAAPH's Helm client uses.
    valuesTemplate: std.manifestYamlDoc(std.mergePatch(baseValues, {
      gatewayAPI: { enabled: false },
    })),
  },
}
