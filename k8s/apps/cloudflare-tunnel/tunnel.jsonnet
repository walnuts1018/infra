function(nameOverride='', replicas=3, enableServiceMonitor=true) {
  apiVersion: 'cf-tunnel-operator.walnuts.dev/v1beta1',
  kind: 'CloudflareTunnel',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: replicas,
    default: true,
    enableServiceMonitor: enableServiceMonitor,
    settings: {
      nameOverride: nameOverride,
    },
    argsOverride: [
      '--no-autoupdate',
      '--protocol',
      'http2',
      '--metrics=0.0.0.0:60123',
      'tunnel',
      'run',
    ],
    resources: {
      requests: {
        cpu: '10m',
        memory: '30Mi',
      },
      limits: {
        cpu: '1',
        memory: '1Gi',
      },
    },
    securityContext: {
      privileged: true,
    },
  },
}
