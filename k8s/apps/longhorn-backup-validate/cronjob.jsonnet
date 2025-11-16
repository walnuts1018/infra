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
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'cluster-deploy',
                image: 'registry.k8s.io/kubectl:v1.34.1',
                command: [
                  '/usr/bin/bash',
                  '-c',
                ],
                args: [
                  'kubectl apply -f /manifests',
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
                    name: 'manifests',
                    mountPath: '/manifests',
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
                name: 'cluster-deploy',
                image: 'debian:13.1-slim',
                command: [
                  '/usr/bin/bash',
                  '-c',
                ],
                args: [
                  'PATH=$PATH:/kubectl bash /scripts/wait_k3s-control-plane.sh',
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
                  },
                ],
                securityContext: {
                  privileged: true,
                },
              },
            ],
            volumes: [
              {
                name: 'manifests',
                emptyDir: {},
              },
              {
                name: 'helm',
                image: {
                  reference: 'alpine/helm:3.19.0',
                },
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
              {
                name: 'charts',
                emptyDir: {},
              },
              {
                name: 'kubectl',
                image: {
                  reference: 'registry.k8s.io/kubectl:v1.34.1',
                },
              },
            ],
          },
        },
      },
    },
  },
}
