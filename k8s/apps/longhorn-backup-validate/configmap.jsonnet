(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-manifests',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'kustomization.yaml': (importstr './_manifests/kustomization.yaml'),
    'cluster.json': std.toString((import './_manifests/cluster.jsonnet')),
    'kubevirt-cluster.json': std.toString((import './_manifests/kubevirt-cluster.jsonnet')),
    'machine-deployment.json': std.toString((import './_manifests/machine-deployment.jsonnet')),
    'talos-control-plane.json': std.toString((import './_manifests/talos-control-plane.jsonnet')),
  },
}
