local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
function(
  clusterID=1,
  clusterName='kurumi',
  k8sServiceHost='192.168.0.17',
  k8sServicePort=16443,
  ingressLoadBalancerIP='192.168.0.129',
  enableServiceMonitor=true,
  operatorReplicas=2,
  usek3s=false,
) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'cilium',
  repoURL: 'https://helm.cilium.io/',
  targetRevision: '1.19.5',
  valuesObject: std.mergePatch(
    std.parseYaml(values), {
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
