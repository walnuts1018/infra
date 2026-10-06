function(app)
  (import '../../ai-services/queue-scaledobject.libsonnet')(app, app.name + '-index-commit-worker', 'picca.ai-result', 0, 2, '20')
