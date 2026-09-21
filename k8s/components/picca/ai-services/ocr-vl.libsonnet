function(app) {
  local workerName = app.name + '-ocr-vl-worker',
  deployment: (import '../_internal/ai-services/ocr-vl/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/ai-services/queue-scaledobject.libsonnet')(app, workerName, 'picca.ai-ocr-vl', 0, 1, '1', 60),
}
