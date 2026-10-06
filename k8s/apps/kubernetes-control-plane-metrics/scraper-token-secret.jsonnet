local app = import 'app.json5';
local serviceAccount = import 'scraper-service-account.jsonnet';
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: app.name + '-scrape-token',
    namespace: app.namespace,
    annotations: {
      'kubernetes.io/service-account.name': serviceAccount.metadata.name,
    },
  },
  type: 'kubernetes.io/service-account-token',
}
