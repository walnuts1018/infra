local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-search-store-plan',
    namespace: app.namespace,
  },
  data: {
    'search-store.ndjson': std.manifestJsonEx({
      '@type': 'update',
      object: 'SearchStore',
      value: {
        '@type': 'ElasticSearch',
        url: 'https://stalwart-search-es-http.stalwart.svc:9200',
        allowInvalidCerts: true,
        httpAuth: {
          '@type': 'Basic',
          username: 'elastic',
          secret: {
            '@type': 'EnvironmentVariable',
            variableName: 'STALWART_ELASTICSEARCH_PASSWORD',
          },
        },
        numShards: 1,
        numReplicas: 0,
        includeSource: false,
      },
    }, '') + '\n',
  },
}
