local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
local appname = app.name + '-migration';
local env = [
  {
    name: 'DATABASE_URL',
    valueFrom: {
      secretKeyRef: {
        name: externalSecret.spec.target.name,
        key: 'DATABASE_URL',
      },
    },
  },
  {
    name: 'DEFAULT_USER_EMAIL',
    value: 'admin@vrt.local.walnuts.dev',
  },
  {
    name: 'DEFAULT_USER_PASSWORD',
    valueFrom: {
      secretKeyRef: {
        name: externalSecret.spec.target.name,
        key: 'DEFAULT_USER_PASSWORD',
      },
    },
  },
  {
    name: 'DEFAULT_USER_API_KEY',
    valueFrom: {
      secretKeyRef: {
        name: externalSecret.spec.target.name,
        key: 'DEFAULT_USER_API_KEY',
      },
    },
  },
];
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: appname + '-' + std.md5(std.toString(env))[0:10],
    namespace: app.namespace,
    labels: labels(appname),
  },
  spec: {
    template: {
      metadata: {
        labels: labels(appname),
      },
      spec: {
        restartPolicy: 'Never',
        containers: [
          (container) {
            name: 'migration',
            image: 'docker.io/visualregressiontracker/migration:5.3.0',
            imagePullPolicy: 'IfNotPresent',
            env: env,
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,
            },
          },
        ],
      },
    },
  },
}
