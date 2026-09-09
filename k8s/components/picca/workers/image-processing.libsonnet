function(app) {
  deployment: (import '../_internal/workers/image-processing/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/image-processing/scaledobject.libsonnet')(app),
}
