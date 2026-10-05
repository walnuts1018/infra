function(app) {
  local workerName = app.name + '-ocr-worker',
  deployment: (import '../_internal/ai-services/ocr/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, workerName, 'picca.ai-ocr', 0, 1, '1', 45),
}
