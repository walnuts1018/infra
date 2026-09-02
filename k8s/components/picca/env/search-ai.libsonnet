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
      value: dbName + '_media',
    },
    {
      name: 'DENSE_SERVICE_URL',
      value: 'http://picca-dense-service.' + app.namespace + '.svc.cluster.local:8001',
    },
    {
      name: 'SPARSE_SERVICE_URL',
      value: 'http://picca-sparse-service.' + app.namespace + '.svc.cluster.local:8002',
    },
    {
      name: 'OCR_SERVICE_URL',
      value: 'http://picca-ocr-service.' + app.namespace + '.svc.cluster.local:8003',
    },
    {
      name: 'CAPTION_SERVICE_URL',
      value: 'http://picca-caption-service.' + app.namespace + '.svc.cluster.local:8004',
    },
  ]
