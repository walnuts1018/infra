{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '20 4 */7 * *',  // 適当
    suspend: true,  // 手動起動のみ
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
          },
          spec: {
            restartPolicy: 'OnFailure',
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'copy-helm',
                image: 'alpine/helm:3.19.0',
                command: [
                  '/bin/sh',
                  '-c',
                ],
                args: [
                  'cp /usr/bin/helm /helm/helm',
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '128Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'helm',
                    mountPath: '/helm',
                  },
                ],
              },
              (import '../../components/container.libsonnet') {
                name: 'build-manifest',
                image: 'registry.k8s.io/kustomize/kustomize:v5.8.0',
                command: [
                  '/bin/sh',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/helm && kustomize build --enable-helm /src -o /manifests/manifest.yaml',
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '128Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'src-manifest',
                    mountPath: '/src',
                    readOnly: true,
                  },
                  {
                    name: 'src-manifest-credentials',
                    mountPath: '/src/credentials',
                    readOnly: true,
                  },
                  {
                    name: 'manifests',
                    mountPath: '/manifests',
                  },
                  {
                    name: 'helm',
                    mountPath: '/helm',
                  },
                  {
                    name: 'tmp',
                    mountPath: '/tmp',
                  },
                  {
                    name: 'charts',
                    mountPath: '/src/charts',
                  },
                ],
              },
            ],
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'k3s',
                  image: 'rancher/k3s:v1.34.1-k3s1',
                  command: [
                    '/bin/k3s',
                    'server',
                  ],
                  resources: {
                    requests: {
                      cpu: '10m',
                      memory: '10Mi',
                    },
                    limits: {
                      cpu: '1',
                      memory: '4Gi',
                    },
                  },
                  ports: [
                    {
                      name: 'metrics',
                      containerPort: 9250,
                    },
                  ],
                  volumeMounts: [
                    {
                      name: 'manifests',
                      mountPath: '/var/lib/rancher/k3s/server/manifests',
                      readOnly: true,
                    },
                  ],
                }, {
                  securityContext: {
                    readOnlyRootFilesystem: false,
                  },
                }
              ),
            ],
            volumes: [
              {
                name: 'src-manifest',
                configMap: {
                  name: (import 'configmap.jsonnet').metadata.name,
                },
              },
              {
                name: 'src-manifest-credentials',
                secret: {
                  secretName: (import 'external-secret.jsonnet').spec.target.name,
                },
              },
              {
                name: 'manifests',
                emptyDir: {},
              },
              {
                name: 'helm',
                emptyDir: {},
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
              {
                name: 'charts',
                emptyDir: {},
              },
            ],
          },
        },
      },
    },
  },
}
