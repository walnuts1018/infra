(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-manifests',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'kustomization.yaml': (importstr './_manifests/kustomization.yaml'),
    'cluster-resource-set.json': std.toString((import './_manifests/cluster-resource-set.jsonnet')),
    'cluster.json': std.toString((import './_manifests/cluster.jsonnet')),
    'external-secret.json': std.toString((import './_manifests/external-secret.jsonnet')),
    'helm-chart-proxy-longhorn.json': std.toString((import './_manifests/helm-chart-proxy-longhorn.jsonnet')),
    'helm-chart-proxy-velero.json': std.toString((import './_manifests/helm-chart-proxy-velero.jsonnet')),
    'kubevirt-cluster.json': std.toString((import './_manifests/kubevirt-cluster.jsonnet')),
    'machine-health-check.json': std.toString((import './_manifests/machine-health-check.jsonnet')),
    'machine-deployment.json': std.toString((import './_manifests/machine-deployment.jsonnet')),
    'talos-control-plane.json': std.toString((import './_manifests/talos-control-plane.jsonnet')),
  },
}
