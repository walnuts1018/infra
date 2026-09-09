function(app) {
  deployment: (import '../_internal/ai-services/ocr/deployment.libsonnet')(app),
  service: (import '../_internal/ai-services/ocr/service.libsonnet')(app),
}
