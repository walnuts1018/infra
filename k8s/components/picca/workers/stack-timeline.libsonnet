function(app) {
  deployment: (import '../_internal/workers/stack-timeline/deployment.libsonnet')(app),
  scaledObject: (import '../_internal/workers/stack-timeline/scaledobject.libsonnet')(app),
}
