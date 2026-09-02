function(app) {
  deployment: (import '../_internal/workers/embedding/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/embedding/scaledobject.libsonnet')(app),
}
