// TartベースのTalos worker(MachineDeployment)を1組まるごと作るための公開API。
// tart-control-plane-stack.libsonnetのworker版。nameはMachineDeployment/TartMachineTemplate/
// TartBootstrapConfigTemplate/patches Secretの名前のsuffixとして使う(例: 'worker' -> 'kurumi-worker')。
//
// opts: hostSelectorLabels, schematicID, patches, replicas
function(cluster, name, opts) {
  local baseName = cluster.name + '-' + name,
  local machineTemplateName = baseName,
  local bootstrapConfigTemplateName = baseName,
  // Tart v0.3.16 requires the referenced Secret to be immutable. Include the
  // patch content in the name so a patch change creates a new Secret instead
  // of attempting to update an immutable one.
  local patchesSecretName = baseName + '-patches-' + std.md5(opts.patches)[0:10],

  machineTemplate: (import '_internal/tart-machine-template.libsonnet')(
    cluster, machineTemplateName, opts.hostSelectorLabels, opts.schematicID
  ),
  bootstrapConfigTemplate: (import '_internal/tart-bootstrap-config-template.libsonnet')(
    cluster, bootstrapConfigTemplateName, patchesSecretName
  ),
  patchesSecret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: { name: patchesSecretName, namespace: cluster.namespace },
    immutable: true,
    type: 'Opaque',
    stringData: { patches: opts.patches },
  },
  machineDeployment: (import '_internal/tart-worker-machine-deployment.libsonnet')(
    cluster, baseName, machineTemplateName, bootstrapConfigTemplateName, opts.replicas
  ),
}
