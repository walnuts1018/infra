function(app) {
  deployment: (import '../_internal/workers/index-commit/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/index-commit/scaledobject.libsonnet')(app),
}
