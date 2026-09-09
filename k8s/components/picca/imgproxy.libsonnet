function(app) {
  deployment: (import '_internal/imgproxy/deployment.libsonnet')(app),
  service: (import '_internal/imgproxy/service.libsonnet')(app),
  servicemonitor: (import '_internal/imgproxy/servicemonitor.libsonnet')(app),
}
