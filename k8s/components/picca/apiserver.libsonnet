function(app) {
  deployment: (import '_internal/apiserver/deployment.libsonnet')(app),
  service: (import '_internal/apiserver/service.libsonnet')(app),
}
