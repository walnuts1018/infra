function(app) {
  deployment: (import '../_internal/ai-services/dense/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/dense/service.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, app.name + '-dense-service', 'picca.ai-dense', 1, 2, '1'),
}
