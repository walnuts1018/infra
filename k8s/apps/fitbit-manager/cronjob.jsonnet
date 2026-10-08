local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    schedule: '*/15 * * * *',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 12000,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            labels: labels(app.name),
          },
          spec: {
            restartPolicy: 'OnFailure',
            securityContext: {
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            containers: [
              (import '../../components/container.libsonnet') {
                name: 'fitbit-manager',
                image: 'ghcr.io/walnuts1018/fitbit-manager:1.0.5@sha256:08640c29786fcfbd23571f43c4b91e7f9ae1d6b755b398a0a9017839333636f6',
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
