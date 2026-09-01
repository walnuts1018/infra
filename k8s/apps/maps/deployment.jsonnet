local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configName = (import 'configmap-name.libsonnet').name;
local sa = import 'sa.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-versatiles-server',
    namespace: app.namespace,
    labels: labels(app.name + '-versatiles-server'),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: labels(app.name + '-versatiles-server'),
    },
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxUnavailable: 0,
        maxSurge: 1,
      },
    },
    template: {
      metadata: {
        labels: labels(app.name + '-versatiles-server'),
      },
      spec: {
        serviceAccountName: sa.metadata.name,
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
        },
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: labels(app.name + '-versatiles-server'),
            },
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'versatiles',
            image: 'docker.io/versatiles/versatiles:v4.12.2',
            imagePullPolicy: 'IfNotPresent',
            args: ['serve', '--config', '/config/config.yaml'],
            securityContext+: {
              allowPrivilegeEscalation: false,
            },
            ports: [
              { name: 'http', containerPort: 8080 },
            ],
            startupProbe: {
              httpGet: { path: '/status', port: 8080 },
              periodSeconds: 2,
              failureThreshold: 30,
            },
            readinessProbe: {
              httpGet: { path: '/status', port: 8080 },
              periodSeconds: 10,
              failureThreshold: 3,
            },
            livenessProbe: {
              httpGet: { path: '/status', port: 8080 },
              periodSeconds: 10,
              failureThreshold: 3,
            },
            resources: {
              requests: {
                cpu: '100m',
                memory: '320Mi',
              },
              limits: {
                cpu: '1',
                memory: '768Mi',
              },
            },
            volumeMounts: [
              { name: 'config', mountPath: '/config', readOnly: true },
            ],
          },
        ],
        // このConfigMapはjsonnet(ArgoCD管理)ではなく、update-cronjobがkubectl applyで
        // 都度書き込む(presigned URLを含む動的な内容のため)。初回デプロイ時、
        // CronJobを一度手動実行するまでこのConfigMapが存在せずPodは起動できない。
        volumes: [
          { name: 'config', configMap: { name: configName } },
        ],
      },
    },
  },
}
