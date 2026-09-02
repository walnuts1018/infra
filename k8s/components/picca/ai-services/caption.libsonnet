function(app) {
  deployment: (import '../_internal/ai-services/caption/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/caption/service.libsonnet')(app),
}
