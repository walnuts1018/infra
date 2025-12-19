local appname = (import 'app.json5').name + '-setup';
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: appname + '-' + std.md5(
      std.toString($.spec) +
      std.toString(import 'configmap-setup.jsonnet') +
      std.toString(import 'external-secret-users.jsonnet')
    )[0:10],
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')(appname),
  },
  spec: {
    // ttlSecondsAfterFinished: 60,
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')(appname),
      },
      spec: {
        restartPolicy: 'OnFailure',
        containers: [
          {
            name: 'setup',
            image: 'scylladb/scylla:2025.4.0',
            command: ['/bin/bash'],
            args: [
              '-c',
              'export PATH=$PATH:/jq && bash /scripts/setup.sh',
            ],
            env: [
              { name: 'SCYLLA_HOST', value: (import 'app.json5').name + '-client' },
              { name: 'SCYLLA_PORT', value: '9142' },
              {
                name: 'SCYLLA_ADMIN_USER',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret-users.jsonnet').spec.target.name,
                    key: 'admin_username',
                  },
                },
              },
              {
                name: 'SCYLLA_ADMIN_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret-users.jsonnet').spec.target.name,
                    key: 'admin_password',
                  },
                },
              },
            ],
            volumeMounts: [
              { name: 'admin-certs', mountPath: '/certs/admin', readOnly: true },
              { name: 'serving-ca', mountPath: '/certs/ca', readOnly: true },
              { name: 'scripts', mountPath: '/scripts', readOnly: true },
              { name: 'keyspaces-config', mountPath: '/config/keyspaces.json', subPath: 'keyspaces.json', readOnly: true },
              { name: 'users-config', mountPath: '/config/users.json', subPath: 'users.json', readOnly: true },
              { name: 'jq', mountPath: '/jq', readOnly: true },
            ],
          },
        ],
        volumes: [
          {
            name: 'admin-certs',
            secret: {
              secretName: (import 'app.json5').name + '-local-user-admin',
              items: [
                { key: 'tls.crt', path: 'tls.crt' },
                { key: 'tls.key', path: 'tls.key' },
              ],
            },
          },
          {
            name: 'serving-ca',
            configMap: {
              name: (import 'app.json5').name + '-local-serving-ca',
              items: [
                { key: 'ca-bundle.crt', path: 'ca-bundle.crt' },
              ],
            },
          },
          {
            name: 'scripts',
            configMap: {
              name: (import 'configmap-setup.jsonnet').metadata.name,
              items: [
                {
                  key: 'setup.sh',
                  path: 'setup.sh',
                },
              ],
            },
          },
          {
            name: 'keyspaces-config',
            configMap: {
              name: (import 'configmap-setup.jsonnet').metadata.name,
              items: [
                {
                  key: 'keyspaces.json',
                  path: 'keyspaces.json',
                },
              ],
            },
          },
          {
            name: 'users-config',
            secret: {
              secretName: (import 'external-secret-users.jsonnet').spec.target.name,
              items: [
                {
                  key: 'users.json',
                  path: 'users.json',
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
