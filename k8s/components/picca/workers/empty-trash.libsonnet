function(app) {
  deployment: (import '../_internal/workers/empty-trash/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/empty-trash/scaledobject.libsonnet')(app),
}
