{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'maple',
            image: 'ghcr.io/walnuts1018/maple:v0.0.12',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
              requests: {
                cpu: '5m',
                memory: '120Mi',
              },
            },
            livenessProbe: {
              httpGet: {
                path: '/',
                port: 3000,
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/',
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
