function(
  clusterID=1,
  clusterName='kurumi',
  k8sServiceHost='192.168.0.17',
  k8sServicePort=16443,
  ingressLoadBalancerIP='192.168.0.129',
  clusterMeshLoadBalancerIP='192.168.0.139',
  enableServiceMonitor=true,
  operatorReplicas=2,
  usek3s=false
) (import '../../components/helm.libsonnet') {
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
          loadBalancerIP: ingressLoadBalancerIP,
        },
      },
      cluster: {
        id: clusterID,
        name: clusterName,
      },
      clustermesh: {
        apiserver: {
          service: {
            loadBalancerIP: clusterMeshLoadBalancerIP,
          },
          metrics: {
            serviceMonitor: {
              enabled: enableServiceMonitor,
            },
          },
        },
      },
      hubble: {
        relay: {
          prometheus: {
            serviceMonitor: {
              enabled: enableServiceMonitor,
            },
          },
        },
        metrics: {
          serviceMonitor: {
            enabled: enableServiceMonitor,
          },
        },
      },
      envoy: {
        prometheus: {
          serviceMonitor: {
            enabled: enableServiceMonitor,
          },
        },
      },
      operator: {
        prometheus: {
          serviceMonitor: {
            enabled: enableServiceMonitor,
          },
        },
        replicas: operatorReplicas,
      },
      prometheus: {
        serviceMonitor: {
          enabled: enableServiceMonitor,
        },
      },
      [if usek3s then 'ipam']: {
        operator: {
          clusterPoolIPv4PodCIDRList: '10.42.0.0/16',
        },
      },
    }
  ),
}
