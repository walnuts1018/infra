function(loadBalancerIP, minReplicas) {
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'EnvoyProxy',
  metadata: (import 'envoy-proxy-metadata.libsonnet'),
  spec: {
    provider: {
      type: 'Kubernetes',
      kubernetes: {
        envoyDeployment: {
          replicas: minReplicas,
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
          minReplicas: minReplicas,
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
          type: 'LoadBalancer',
          loadBalancerIP: loadBalancerIP,
        },
      },
    },
    // logging: {
    //   level: {
    //     default: 'debug',
    //     jwt: 'debug',
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
