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
          {
            name: 'fitbit-manager',
            image: 'ghcr.io/walnuts1018/fitbit-manager:0.8.7',
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
            env: [
              {
                name: 'USER_ID',
                value: 'B84M2S',
              },
              {
                name: 'CLIENT_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client_id',
                  },
                },
              },
              {
                name: 'CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client_secret',
                  },
                },
              },
              {
                name: 'COOKIE_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'cookie_secret',
                  },
                },
              },
              {
                name: 'PSQL_HOST',
                value: 'postgresql-default.databases.svc.cluster.local',
              },
              {
                name: 'PSQL_PORT',
                value: '5432',
              },
              {
                name: 'PSQL_DATABASE',
                value: 'fitbit_manager',
              },
              {
                name: 'PSQL_USER',
                value: 'fitbit_manager',
              },
              {
                name: 'PSQL_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'postgres_password',
                  },
                },
              },
              {
                name: 'INFLUXDB_ENDPOINT',
                value: 'http://influxdb-influxdb2.databases.svc.cluster.local',
              },
              {
                name: 'INFLUXDB_AUTH_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'influxdb_auth_token',
                  },
                },
              },
              {
                name: 'INFLUXDB_ORG',
                value: 'influxdata',
              },
              {
                name: 'INFLUXDB_BUCKET',
                value: 'fitbit_manager',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_INSECURE',
                value: 'true',
              },
            ],
          },
        ],
      },
    },
  },
}
