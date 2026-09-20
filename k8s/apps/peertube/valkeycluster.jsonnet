local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local redisSecret = import 'external-secret-redis.jsonnet';
{
  apiVersion: 'valkey.io/v1alpha1',
  kind: 'ValkeyCluster',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels(app.name + '-valkey'),
  },
  spec: {
    shards: 1,
    replicas: 2,
    users: [
      {
        name: 'default',
        enabled: true,
        permissions: '+@all ~* &*',
        passwordSecret: {
          name: redisSecret.spec.target.name,
          keys: ['valkey_password'],
        },
      },
    ],
    resources: {
      requests: { cpu: '5m', memory: '32Mi' },
      limits: { cpu: '1', memory: '1Gi' },
    },
  },
}
