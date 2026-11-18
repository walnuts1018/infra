{
  manifest(stage): std.manifestYamlDoc({
    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      name: 'agr-' + stage + '-{{workflow.name}}',
      namespace: 'agr',
    },
  }),
}
