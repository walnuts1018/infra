// TartベースのTalos control planeを1組まるごと作るための公開API。
// cluster.jsonnet横の1ファイル(例: tart-control-plane.jsonnet)からflatten-resources.libsonnet経由で
// 展開して使うことを想定している。個々のCRDの実装は_internal/以下にある。
//
// opts:
//   controlPlaneEndpointHost, controlPlaneEndpointPort: Cluster.spec.controlPlaneEndpoint
//   hostSelectorLabels: control planeノードを選ぶTartHostのラベル
//   schematicID: Talos Image FactoryのschematicID
//   patches: TartBootstrapConfigTemplateへ渡す生Talos config patch(YAML文字列。importstrで渡す)
//   replicas: 省略時はcluster.controlPlaneMachineCount
//   podCIDRs, serviceCIDRs: 省略時はbiscuit/kurumi共通のデフォルト値
function(cluster, opts) {
  local baseName = cluster.name + '-control-plane',
  local templateHash = std.md5(std.manifestJson({
    patches: opts.patches,
    schematicID: opts.schematicID,
    talosVersion: cluster.talosVersion,
    hostSelectorLabels: opts.hostSelectorLabels,
  }))[0:10],
  local machineTemplateName = baseName + '-' + templateHash,
  local bootstrapConfigTemplateName = baseName + '-' + templateHash,
  // Tart v0.3.16 requires the referenced Secret to be immutable. Include the
  // patch content in the name so a patch change creates a new Secret instead
  // of attempting to update an immutable one.
  local patchesSecretName = baseName + '-patches-' + templateHash,

  cluster: (import '_internal/cluster.libsonnet')(
    cluster,
    opts.controlPlaneEndpointHost,
    opts.controlPlaneEndpointPort,
    cluster.name,
    cluster.name,
    std.get(opts, 'podCIDRs', ['10.244.0.0/16']),
    std.get(opts, 'serviceCIDRs', ['10.96.0.0/12']),
  ),
  tartCluster: (import '_internal/tart-cluster.libsonnet')(cluster),
  machineTemplate: (import '_internal/tart-machine-template.libsonnet')(
    cluster, machineTemplateName, opts.hostSelectorLabels, opts.schematicID
  ),
  bootstrapConfigTemplate: (import '_internal/tart-bootstrap-config-template.libsonnet')(
    cluster, bootstrapConfigTemplateName, patchesSecretName
  ),
  patchesSecret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: patchesSecretName,
      namespace: cluster.namespace,
      annotations: { 'argocd.argoproj.io/sync-options': 'Prune=false' },
    },
    immutable: true,
    type: 'Opaque',
    stringData: { patches: opts.patches },
  },
  controlPlane: (import '_internal/tart-control-plane.libsonnet')(
    cluster, machineTemplateName, bootstrapConfigTemplateName, std.get(opts, 'replicas', cluster.controlPlaneMachineCount)
  ),
}
