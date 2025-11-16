{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '20 4 */7 * *',  // 適当
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
            dnsPolicy: 'Default',
            serviceAccountName: (import 'sa.jsonnet').metadata.name,
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'cluster-deploy',
                image: 'debian:13.1-slim',
                command: [
                  '/usr/bin/bash',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/kustomize:/kubectl && kustomize build /manifests | kubectl apply -f -',
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '128Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '512Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'manifests',
                    mountPath: '/manifests',
                  },
                  {
                    name: 'kubectl',
                    mountPath: '/kubectl',
                    subPath: 'bin',
                  },
                  {
                    name: 'kustomize',
                    mountPath: '/kustomize',
                    subPath: 'app',
                  },
                  {
                    name: 'tmp',
                    mountPath: '/tmp',
                  },
                ],
              },
              (import '../../components/container.libsonnet') {
                name: 'wait-for-cluster',
                image: 'debian:13.1-slim',
                command: [
                  '/usr/bin/bash',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/kubectl && bash /scripts/wait-for-cluster.sh',
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '512Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'scripts',
                    mountPath: '/scripts',
                  },
                  {
                    name: 'kubectl',
                    mountPath: '/kubectl',
                    subPath: 'bin',
                  },
                  {
                    name: 'tmp',
                    mountPath: '/tmp',
                  },
                ],
              },
            ],
            containers: [
              (import '../../components/container.libsonnet') {
                name: 'backup-validate',
                image: 'debian:13.1-slim',
                command: [
                  '/usr/bin/bash',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/kubectl && bash /scripts/validate-longhorn-backup.sh',
                ],
                resources: {
                  requests: {
                    cpu: '10m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '1',
                    memory: '512Mi',
                  },
                },
                lifecycle: {
                  preStop: {
                    exec: {
                      command: [
                        '/usr/bin/bash',
                        '-c',
                        'export PATH=$PATH:/kustomize:/kubectl && kustomize build /manifests | kubectl delete -f -',
                      ],
                    },
                  },
                },
                volumeMounts: [
                  {
                    name: 'scripts',
                    mountPath: '/scripts',
                  },
                  {
                    name: 'manifests',
                    mountPath: '/manifests',
                  },
                  {
                    name: 'kubectl',
                    mountPath: '/kubectl',
                    subPath: 'bin',
                  },
                  {
                    name: 'kustomize',
                    mountPath: '/kustomize',
                    subPath: 'app',
                  },
                  {
                    name: 'tmp',
                    mountPath: '/tmp',
                  },
                  {
                    name: 'kubeconfig',
                    mountPath: '/root/.kube/config',
                    subPath: 'kubeconfig',
                  },
                ],
              },
            ],
            volumes: [
              {
                name: 'scripts',
                configMap: {
                  name: (import 'configmap-scripts.jsonnet').metadata.name,
                },
              },
              {
                name: 'manifests',
                configMap: {
                  name: (import 'configmap-manifests.jsonnet').metadata.name,
                },
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
              {
                name: 'kubectl',
                image: {
                  reference: 'registry.k8s.io/kubectl:v1.34.1',
                },
              },
              {
                name: 'kubeconfig',
                secret: {
                  secretName: (import '_manifests/cluster.jsonnet').metadata.name + '-kubeconfig',
                },
              },
              {
                name: 'kustomize',
                image: {
                  reference: 'registry.k8s.io/kustomize/kustomize:v5.8.0',
                },
              },
            ],
          },
        },
      },
    },
  },
}
