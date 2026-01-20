{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        securityContext: {
          runAsUser: 10001,
          runAsGroup: 65534,
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'walnuts-dev',
            image: 'ghcr.io/walnuts1018/walnuts.dev:0a7ffd545238c9a2001c048e2e4284ca570637c8-671',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              requests: {
                cpu: '8m',
                memory: '160Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            env: [
              {
                name: 'NEXT_PUBLIC_GA_ID',
                value: 'G-NB6F68ZQ9P',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
            },
            volumeMounts: [
              {
                name: 'next-cache',
                mountPath: '/app/.next/cache',
              },
            ],
          }, {
            securityContext: {
              runAsNonRoot: true,
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        priorityClassName: 'high',
        affinity: {
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'app',
                        operator: 'In',
                        values: [
                          (import 'app.json5').name,
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
          nodeAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                preference: {
                  matchExpressions: [
                    {
                      key: 'kubernetes.io/arch',
                      operator: 'In',
                      values: [
                        'amd64',
                      ],
                    },
                  ],
                },
              },
              {
                weight: 10,
                preference: {
                  matchExpressions: [
                    {
                      key: 'kubernetes.io/hostname',
                      operator: 'NotIn',
                      values: [
                        'donut',
                      ],
                    },
                  ],
                },
              },
            ],
          },
        },
        volumes: [
          {
            name: 'next-cache',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
