local app = import 'app.json5';
(import '../../components/pdb.libsonnet')(
  name=app.name,
  namespace=app.namespace,
  labels=(import '../../components/labels.libsonnet')(app.name),
  minAvailable=1
)
