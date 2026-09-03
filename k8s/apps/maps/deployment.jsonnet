local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local envoyConfig = import 'configmap-envoy.jsonnet';
local config = import 'configmap.jsonnet';
local sa = import 'sa.jsonnet';
local readSecretName = (import '../../components/seaweedfs-s3-credentials.libsonnet')('maps_read').secretName;
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-versatiles-server',
    namespace: app.namespace,
    labels: labels(app.name + '-versatiles-server'),
  },
  spec: {
    replicas: 1,
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
          runAsUser: 65532,
          runAsGroup: 65532,
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
        initContainers: [
          (import '../../components/container.libsonnet') {
            name: 'envoy-s3-proxy',
            image: 'docker.io/envoyproxy/envoy:distroless-v1.39.0',
            imagePullPolicy: 'IfNotPresent',
            restartPolicy: 'Always',
            command: ['envoy'],
            args: ['-c', '/etc/envoy/envoy.yaml'],
            envFrom: [
              { secretRef: { name: readSecretName } },
            ],
            securityContext+: {
              allowPrivilegeEscalation: false,
            },
            readinessProbe: {
              httpGet: { path: '/ready', port: 9901 },
              periodSeconds: 5,
              failureThreshold: 6,
            },
            resources: {
              requests: {
                cpu: '30m',
                memory: '48Mi',
              },
              limits: {
                memory: '256Mi',
              },
            },
            volumeMounts: [
              { name: 'envoy-config', mountPath: '/etc/envoy', readOnly: true },
            ],
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'versatiles',
            image: 'docker.io/versatiles/versatiles:v4.12.3',
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
        volumes: [
          { name: 'config', configMap: { name: config.metadata.name } },
          { name: 'envoy-config', configMap: { name: envoyConfig.metadata.name } },
        ],
      },
    },
  },
}
