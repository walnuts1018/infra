function(app) {
  deployment: (import 'deployment.libsonnet')(app),
  service: (import 'service.libsonnet')(app),
}
