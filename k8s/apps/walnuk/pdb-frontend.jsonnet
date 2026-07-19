local app = import 'app.json5';
(import '../../components/pdb.libsonnet')(
  name=app.appname.frontend,
  namespace=app.namespace,
  labels=(import '../../components/labels.libsonnet')(app.appname.frontend),
  minAvailable=1
)
