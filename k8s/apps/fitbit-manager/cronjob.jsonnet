{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
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
              {
                name: 'fitbit-manager',
                image: 'ghcr.io/walnuts1018/fitbit-manager:1.0.4',
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
                  limits: {
                    memory: '300Mi',
                  },
                  requests: {
                    memory: '10Mi',
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
