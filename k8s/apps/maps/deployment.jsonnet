local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local config = import 'configmap.jsonnet';
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
            // versatiles-rsの`/status`はプロセス起動直後から常に200を返す軽量なliveness用
            // endpoint(公式ソースコード上のコメントで明記)。Kubernetesのhttpget probeは
            // status codeしか見ないため、`/tiles/index.json`を使ってもbodyの中身までは
            // 検証できず実益がない。重いtile取得をprobeにしないという方針も満たす。
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
              // VersaTilesのデフォルトchunk読み込みバジェット(VERSATILES_CHUNK_READ_MEMORY)は
              // 256MiB。上書きはせずデフォルトのまま使うため、それに見合う値にする。
              requests: { cpu: '100m', memory: '320Mi' },
              limits: { cpu: '1', memory: '768Mi' },
            },
            volumeMounts: [
              { name: 'config', mountPath: '/config', readOnly: true },
            ],
          },
        ],
        volumes: [
          { name: 'config', configMap: { name: config.metadata.name } },
        ],
      },
    },
  },
}
