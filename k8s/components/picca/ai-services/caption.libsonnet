function(app) {
  local workerName = app.name + '-caption-worker',
  local workerLabels = (import '../../labels.libsonnet')(workerName),
  deployment: (import '../_internal/ai-services/caption/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/worker-service.libsonnet')(app, workerName, workerLabels, 8004),
  scaledObject: (import '../_internal/ai-services/worker-scaledobject.libsonnet')(app, workerName),
  interceptorRoute: (import '../_internal/ai-services/interceptor-route.libsonnet')(app, workerName, workerName + '-backend', 8004, 1),
}
