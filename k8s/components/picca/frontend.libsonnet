function(app) {
  deployment: (import '_internal/frontend/deployment.libsonnet')(app),
  service: (import '_internal/frontend/service.libsonnet')(app),
}
