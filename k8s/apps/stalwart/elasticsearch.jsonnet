local app = import 'app.json5';
{
  apiVersion: 'elasticsearch.k8s.elastic.co/v1',
  kind: 'Elasticsearch',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
  spec: {
    version: '9.4.2',
    volumeClaimDeletePolicy: 'DeleteOnScaledownOnly',
    nodeSets: [
      {
        name: 'default',
        count: 1,
        config: {
          'node.store.allow_mmap': false,
        },
        podTemplate: {
          spec: {
            containers: [
              {
                name: 'elasticsearch',
                resources: {
                  requests: {
                    cpu: '250m',
                    memory: '1Gi',
                  },
                  limits: {
                    cpu: '1',
                    memory: '2Gi',
                  },
                },
              },
            ],
          },
        },
        volumeClaimTemplates: [
          {
            metadata: {
              name: 'elasticsearch-data',
            },
            spec: {
              accessModes: ['ReadWriteOnce'],
              storageClassName: 'longhorn',
              resources: {
                requests: {
                  storage: '4Gi',
                },
              },
            },
          },
        ],
      },
    ],
  },
}
