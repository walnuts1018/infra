function(nameOverride='', replicas=3, enableServiceMonitor=true) {
  apiVersion: 'cf-tunnel-operator.walnuts.dev/v1beta1',
  kind: 'CloudflareTunnel',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + {
      appname: (import 'app.json5').name,
    },
  },
  spec: {
    replicas: replicas,
    default: true,
    enableServiceMonitor: enableServiceMonitor,
    settings: {
      nameOverride: nameOverride,
    },
    // resources: {
    //   requests: {
    //     cpu: '100m',
    //     memory: '50Mi',
    //   },
    //   limits: {
    //     cpu: '1',
    //     memory: '1Gi',
    //   },
    // },
  },
}
