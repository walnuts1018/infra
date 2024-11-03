{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'machine-status-api',
            image: 'ghcr.io/walnuts1018/machine-status-api:1.2.0',
            imagePullPolicy: 'IfNotPresent',
            securityContext: {
              runAsGroup: 997,
              readOnlyRootFilesystem: true,
              seccompProfile: {
                type: 'RuntimeDefault',
              },
              privileged: true,
            },
            ports: [
              {
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'GIN_MODE',
                value: 'release',
              },
              {
                name: 'PVE_API_URL',
                value: 'invalid',
              },
              {
                name: 'PVE_API_TOKEN_ID',
                value: 'invalid',
              },
              {
                name: 'PVE_API_SECRET',
                value: 'invalid',
              },
            ],
            resources: {
              requests: {
                memory: '10Mi',
              },
              limits: {},
            },
          },
        ],
        priorityClassName: 'high',
        nodeSelector: {
          'kubernetes.io/hostname': 'cheese',
        },
        tolerations: [
          {
            operator: 'Exists',
          },
        ],
      },
    },
  },
}
