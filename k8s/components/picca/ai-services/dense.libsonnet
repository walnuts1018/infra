function(app) {
  deployment: (import '../_internal/ai-services/dense/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/dense/service.libsonnet')(app),
}
