function(k8sServiceHost='192.168.0.17', k8sServicePort=16443, loadBalancerIP='192.168.0.129') (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cilium',
  repoURL: 'https://helm.cilium.io/',
  targetRevision: '1.16.6',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
      k8sServiceHost: k8sServiceHost,
      k8sServicePort: k8sServicePort,
      ingressController: {
        service: {
          loadBalancerIP: loadBalancerIP,
        },
      },
    }
  ),
}
