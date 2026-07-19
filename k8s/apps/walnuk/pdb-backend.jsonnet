local app = import 'app.json5';
(import '../../components/pdb.libsonnet')(
  name=app.appname.backend,
  namespace=app.namespace,
  labels=(import '../../components/labels.libsonnet')(app.appname.backend),
  minAvailable=1
)
