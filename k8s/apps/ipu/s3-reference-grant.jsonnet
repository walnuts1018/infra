local app = import 'app.json5';
(import '../../components/s3-reference-grant.libsonnet')(app.namespace)
