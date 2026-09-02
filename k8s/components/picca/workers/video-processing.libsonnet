function(app) {
  deployment: (import '../_internal/workers/video-processing/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/video-processing/scaledobject.libsonnet')(app),
}
