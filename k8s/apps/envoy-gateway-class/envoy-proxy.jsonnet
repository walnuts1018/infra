function(loadBalancerIP='192.168.0.138') {
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'EnvoyProxy',
  metadata: {
    name: 'custom-config',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    provider: {
      type: 'Kubernetes',
      kubernetes: {
        envoyDeployment: {
          replicas: 2,
          container: {
            resources: {
              requests: {
                cpu: '5m',
                memory: '64Mi',
              },
              limits: {
                memory: '1Gi',
              },
            },
          },
        },
        envoyHpa: {
          minReplicas: 2,
          maxReplicas: 5,
          metrics: [
            {
              type: 'Resource',
              resource: {
                name: 'memory',
                target: {
                  type: 'Utilization',
                  averageUtilization: 100,
                },
              },
            },
          ],
        },
        envoyService: {
          loadBalancerIP: loadBalancerIP,
          type: 'LoadBalancer',
        },
      },
    },
    // logging: {
    //   level: {
    //     default: 'debug',
    //   },
    // },
    telemetry: {
      tracing: {
        samplingRate: 100,
        provider: {
          host: 'default-collector.opentelemetry-collector.svc.cluster.local',
          port: 4317,
        },
      },
    },
  },
}
