local app = import 'app.json5';
(import '../../components/picca/_internal/rabbitmq/vhost.libsonnet')(app)
