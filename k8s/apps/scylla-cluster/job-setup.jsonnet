local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configmapSetup = import 'configmap-setup.jsonnet';
local externalSecretMigrations = import 'external-secret-migrations.jsonnet';
local appname = app.name + '-setup';
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: appname + '-' + std.md5(
      std.toString($.spec) +
      std.toString(configmapSetup) +
      std.toString(externalSecretMigrations)
    )[0:10],
    namespace: app.namespace,
    labels: (labels)(appname),
  },
  spec: {
    // ttlSecondsAfterFinished: 60,
    template: {
      metadata: {
        labels: (labels)(appname),
      },
      spec: {
        restartPolicy: 'OnFailure',
        containers: [
          {
            name: 'setup',
            image: 'scylladb/scylla:2025.4.7',
            command: ['/bin/bash'],
            args: [
              '-c',
              'export PATH=$PATH:/jq && bash /scripts/setup.sh',
            ],
            env: [
              { name: 'SCYLLA_HOST', value: app.name + '-client' },
              { name: 'SCYLLA_PORT', value: '9142' },
              {
                name: 'SCYLLA_ADMIN_USER',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecretMigrations.spec.target.name,
                    key: 'admin_username',
                  },
                },
              },
              {
                name: 'SCYLLA_ADMIN_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecretMigrations.spec.target.name,
                    key: 'admin_password',
                  },
                },
              },
            ],
            volumeMounts: [
              { name: 'admin-certs', mountPath: '/certs/admin', readOnly: true },
              { name: 'serving-ca', mountPath: '/certs/ca', readOnly: true },
              { name: 'scripts', mountPath: '/scripts', readOnly: true },
              { name: 'migration-config', mountPath: '/config/migrations.cql', subPath: 'migrations.cql', readOnly: true },
              { name: 'jq', mountPath: '/jq', readOnly: true },
            ],
          },
        ],
        volumes: [
          {
            name: 'admin-certs',
            secret: {
              secretName: app.name + '-local-user-admin',
              items: [
                { key: 'tls.crt', path: 'tls.crt' },
                { key: 'tls.key', path: 'tls.key' },
              ],
            },
          },
          {
            name: 'serving-ca',
            configMap: {
              name: app.name + '-local-serving-ca',
              items: [
                { key: 'ca-bundle.crt', path: 'ca-bundle.crt' },
              ],
            },
          },
          {
            name: 'scripts',
            configMap: {
              name: configmapSetup.metadata.name,
              items: [
                {
                  key: 'setup.sh',
                  path: 'setup.sh',
                },
              ],
            },
          },
          {
            name: 'migration-config',
            secret: {
              secretName: externalSecretMigrations.spec.target.name,
              items: [
                {
                  key: 'migrations.cql',
                  path: 'migrations.cql',
                },
              ],
            },
          },
          {
            name: 'jq',
            image: {
              reference: 'ghcr.io/jqlang/jq:1.8.1',
            },
          },
        ],
      },
    },
  },
}
