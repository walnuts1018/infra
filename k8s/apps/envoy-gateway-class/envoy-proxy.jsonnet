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
      // TODO:  OpenTelemetryを使うと、複数のPodのメトリクスを区別できない
      // https://github.com/envoyproxy/gateway/issues/9093 が実装されたら、resource attributeにPod名を付与するようにする
      //
      // metrics: {
      //   sinks: [
      //     {
      //       type: 'OpenTelemetry',
      //       openTelemetry: {
      //         backendRefs: [
      //           {
      //             name: 'default-collector',
      //             namespace: 'opentelemetry-collector',
      //             port: 4317,
      //           },
      //         ],
      //       },
      //     },
      //   ],
      // },
      tracing: {
        samplingRate: 100,
        provider: {
          type: 'OpenTelemetry',
          backendRefs: [
            {
              name: 'default-collector',
              namespace: 'opentelemetry-collector',
              port: 4317,
            },
          ],
        },
      },
    },
  },
}
