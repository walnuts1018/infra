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
                cpu: '6m',
                memory: '96Mi',
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
          externalTrafficPolicy: 'Cluster',
          loadBalancerIP: loadBalancerIP,
          type: 'LoadBalancer',
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
      metrics: {
        sinks: [
          {
            type: 'OpenTelemetry',
            openTelemetry: {
              backendRefs: [
                {
                  name: 'default-collector',
                  namespace: 'opentelemetry-collector',
                  port: 4317,
                },
              ],
            },
          },
        ],
      },
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
