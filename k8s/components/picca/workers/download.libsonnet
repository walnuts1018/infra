function(app) {
  deployment: (import '../_internal/workers/download/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/download/scaledobject.libsonnet')(app),
}
