function(app) {
  deployment: (import 'deployment.libsonnet')(app),
  scaledObject: (import 'scaledobject.libsonnet')(app),
}
