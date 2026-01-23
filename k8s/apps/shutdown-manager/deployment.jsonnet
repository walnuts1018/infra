{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        containers: [
          std.mergePatch((import '../../components/container.libsonnet'), {
            name: 'proxy',
            image: 'ghcr.io/walnuts1018/shutdown-manager:0.0.11',
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
            },
            securityContext: {
              capabilities: {
                add: [
                  'NET_BIND_SERVICE',
                  'SYS_ADMIN',
                  'CAP_SYS_BOOT',
                ],
              },
              privileged: true,
            },
            resources: {
              limits: {
                cpu: '100m',
                memory: '300Mi',
              },
              requests: {
                cpu: '1m',
                memory: '10Mi',
              },
            },
            volumeMounts: [
              {
                name: 'run-systemd-system',
                mountPath: '/run/systemd/system',
              },
              {
                name: 'var-run-dbus',
                mountPath: '/var/run/dbus',
              },
            ],
          }),
        ],
        volumes: [
          {
            name: 'run-systemd-system',
            hostPath: {
              path: '/run/systemd/system',
            },
          },
          {
            name: 'var-run-dbus',
            hostPath: {
              path: '/var/run/dbus',
            },
          },
        ],
        nodeSelector: {
          'kubernetes.io/os': 'linux',
          'kubernetes.io/hostname': 'biscuit',
        },
      },
    },
  },
}
