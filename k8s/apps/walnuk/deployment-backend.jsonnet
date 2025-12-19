{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').appname.backend,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
      },
      spec: {
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'apiserver',
            image: 'ghcr.io/walnuts1018/walnuk-backend:v0.0.37',
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
                name: 'SCYLLA_CA_CERT_PATH',
                value: '/etc/certs/scylla-db/ca.crt',
              },
              {
                name: 'SCYLLA_CLIENT_CERT_PATH',
                value: '/etc/certs/scylla-db-client/tls.crt',
              },
              {
                name: 'SCYLLA_CLIENT_KEY_PATH',
                value: '/etc/certs/scylla-db-client/tls.key',
              },
              {
                name: 'SCYLLA_URL',
                value: 'scylla-cluster-client.databases.svc.cluster.local:9142',
              },
              {
                name: 'SCYLLA_USER',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'scylladb_username',
                  },
                },
              },
              {
                name: 'SCYLLA_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'scylladb_password',
                  },
                },
              },
              {
                name: 'RUST_BACKTRACE',
                value: '1',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/health/livez',
                port: 8080,
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/health/readyz',
                port: 8080,
              },
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'scylla-db-ca-cert',
                mountPath: '/etc/certs/scylla-db',
                readOnly: true,
              },
              {
                name: 'scylla-db-client-cert',
                mountPath: '/etc/certs/scylla-db-client',
                readOnly: true,
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
          {
            name: 'scylla-db-ca-cert',
            configMap: {
              name: (import 'configmap-scylladb-ca.jsonnet').metadata.name,
              items: [
                {
                  key: 'ca.crt',
                  path: 'ca.crt',
                },
              ],
            },
          },
          {
            name: 'scylla-db-client-cert',
            secret: {
              secretName: 'scylla-cluster-local-client-ca',  // database namespaceから手動コピーしてるけどいい方法を考えないといけない
              items: [
                {
                  key: 'tls.crt',
                  path: 'tls.crt',
                },
                {
                  key: 'tls.key',
                  path: 'tls.key',
                },
              ],
            },
          },
        ],
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
            },
          },
        ],
      },
    },
  },
}
