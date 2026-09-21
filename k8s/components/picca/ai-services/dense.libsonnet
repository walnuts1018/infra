function(app) {
  deployment: [
    (import '../_internal/ai-services/dense/deployment.libsonnet')(app),
    (import '../_internal/ai-services/dense/deployment.libsonnet')(app, 'image'),
  ],
  service: (import '../_internal/ai-services/dense/service.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, app.name + '-dense-worker', 'picca.ai-dense', 0, 1, '1', 60),
}
