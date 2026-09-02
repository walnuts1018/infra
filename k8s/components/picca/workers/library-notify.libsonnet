function(app) {
  deployment: (import '../_internal/workers/library-notify/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/library-notify/scaledobject.libsonnet')(app),
}
