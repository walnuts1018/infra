{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    replicas: 2,
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        securityContext: {
          sysctls: [
            {
              name: 'net.ipv4.ping_group_range',
              value: '0 2147483647',
            },
          ],
        },
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'cloudflared',
            securityContext: {
              readOnlyRootFilesystem: true,
            },
            image: 'cloudflare/cloudflared:2024.11.1',
            imagePullPolicy: 'IfNotPresent',
            args: [
              '--no-autoupdate',
              '--metrics=0.0.0.0:60123',
              'tunnel',
              'run',
            ],
            env: [
              {
                name: 'TUNNEL_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'cloudflared-token',
                  },
                },
              },
            ],
            ports: [
              {
                containerPort: 60123,
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/ready',
                port: 60123,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            resources: {
              requests: {
                memory: '32Mi',
                cpu: '10m',
              },
              limits: {
                memory: '512Mi',
                cpu: '1000m',
              },
            },
          },
        ],
        affinity: {
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 10,
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'app',
                        operator: 'In',
                        values: [
                          'cloudflared',
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
        },
      },
    },
  },
}
