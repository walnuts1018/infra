function(app)
  local dbName = std.strReplace(app.name, '-', '_');
  [
    {
      name: 'QDRANT_HOST',
      value: 'qdrant.qdrant.svc.cluster.local',
    },
    {
      name: 'QDRANT_PORT',
      value: '6334',
    },
    {
      name: 'QDRANT_COLLECTION',
      value: dbName + '_media_v2',
    },
    {
      name: 'DENSE_SERVICE_URL',
      value: 'http://picca-dense-service.' + app.namespace + '.svc.cluster.local:8001',
    },
  ]
