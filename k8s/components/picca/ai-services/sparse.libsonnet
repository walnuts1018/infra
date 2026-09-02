function(app) {
  deployment: (import '../_internal/ai-services/sparse/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/sparse/service.libsonnet')(app),
}
