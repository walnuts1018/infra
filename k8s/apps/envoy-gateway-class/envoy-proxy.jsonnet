{
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
                cpu: '10m',
                memory: '128Mi',
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
          ports: [
            {
              name: 'http-8080',
              port: 8080,
              protocol: 'TCP',
              targetPort: 10080,
            },
          ],
          type: 'LoadBalancer',
        },
      },
    },
  },
}
