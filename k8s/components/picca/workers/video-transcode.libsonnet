function(app) {
  deployment: (import '../_internal/workers/video-transcode/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/video-transcode/scaledobject.libsonnet')(app),
}
