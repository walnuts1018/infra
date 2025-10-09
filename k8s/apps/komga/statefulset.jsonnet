{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    serviceName: (import 'service.jsonnet').metadata.name,
    replicas: 1,
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'komga',
            image: 'gotson/komga:1.23.5',
            resources: {
              limits: {
                cpu: '1',
                memory: '2Gi',
              },
              requests: {
                cpu: '5m',
                memory: '2Gi',
              },
            },
            securityContext:: null,
            ports: [
              {
                containerPort: 25600,
                name: 'http',
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/actuator/health',
                port: 'http',
              },
            },
            env: [
              {
                name: 'JAVA_TOOL_OPTIONS',
                value: '-XX:MaxRAMPercentage=70 -XX:MaxMetaspaceSize=256m',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/config',
                name: 'config-dir',
              },
              {
                mountPath: '/config/application.yml',
                name: 'config-file',
                subPath: 'application.yml',
                readOnly: true,
              },
              {
                mountPath: '/books',
                name: 'book-dir',
              },
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config-dir',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'config-file',
            secret: {
              secretName: (import 'external-secret.jsonnet').spec.target.name,
            },
          },
          {
            name: 'book-dir',
            persistentVolumeClaim: {
              claimName: (import '../samba/pvc-books.jsonnet').metadata.name,
            },
          },
          {
            emptyDir: {},
            name: 'tmp',
          },
        ],
        nodeSelector: {
          'kubernetes.io/hostname': 'cake',
        },
      },
    },
  },
}
