function(app) {
  local workerName = app.name + '-caption-worker',
  deployment: (import '../_internal/ai-services/caption/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, workerName, 'picca.ai-caption', 0, 2, '20'),
}
