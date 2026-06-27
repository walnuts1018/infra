local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local env = import 'env.libsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    schedule: '*/15 * * * *',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 12000,
    jobTemplate: {
      spec: {
        template: {
          spec: {
            restartPolicy: 'OnFailure',
            securityContext: {
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            containers: [
              (import '../../components/container.libsonnet') {
                name: 'fitbit-manager',
                image: 'ghcr.io/walnuts1018/fitbit-manager:1.0.5',
                command: [
                  '/app/fitbit-manager-job',
                ],
                imagePullPolicy: 'IfNotPresent',
                ports: [
                  {
                    containerPort: 8080,
                  },
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '300Mi',
                  },
                },
                env: env.env,
              },
            ],
            tolerations: [
              {
                key: 'node.walnuts.dev/low-performance',
                operator: 'Exists',
              },
            ],
          },
        },
      },
    },
  },
}
