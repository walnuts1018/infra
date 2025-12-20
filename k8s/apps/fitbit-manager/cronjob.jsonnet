{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
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
                env: (import 'env.libsonnet').env,
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
