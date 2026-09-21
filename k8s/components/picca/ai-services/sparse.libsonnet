function(app) {
  deployment: (import '../_internal/ai-services/sparse/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/sparse/service.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, app.name + '-sparse-service', 'picca.ai-sparse', 1, 2, '1'),
}
