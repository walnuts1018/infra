{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'walnuk',
            image: 'ghcr.io/walnuts1018/walnuk:v0.0.27',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '2m',
                memory: '32Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'SCYLLA_URL',
                value: 'scylla-cluster-client.databases.svc.cluster.local:9142',
              },
              {
                name: 'SCYLLA_USER',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secrets.jsonnet').spec.target.name,
                    key: 'scylladb_username',
                  },
                },
              },
              {
                name: 'SCYLLA_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secrets.jsonnet').spec.target.name,
                    key: 'scylladb_password',
                  },
                },
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 8080,
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 8080,
              },
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
          }, {
            securityContext: {
              runAsNonRoot: true,
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        priorityClassName: 'high',
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
