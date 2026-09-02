function(app, useSuffix=true)
  local valkeySecret = (import 'valkey/secret.libsonnet')(app, useSuffix);
  local rabbitmqSecret = (import 'rabbitmq/secret.libsonnet')(app, useSuffix);
  {
    sa: (import 'sa.libsonnet')(app),
    postgresSecret: (import 'postgres/secret.libsonnet')(app, useSuffix),
    scyllaSecret: (import 'scylla/secret.libsonnet')(app, useSuffix),
    valkeySecret: valkeySecret,
    oidcSecret: (import 'oidc/secret.libsonnet')(app, useSuffix),
    rabbitmqSecret: rabbitmqSecret,
    graphqlSigningSecret: (import 'common/graphql-signing-secret.libsonnet')(app, useSuffix),
    imgproxySecret: (import 'imgproxy/secret.libsonnet')(app, useSuffix),

    configmapPlans: (import 'common/plans/configmap.libsonnet')(app, useSuffix),
    configmapScylladbCa: (import 'scylla/configmap-ca.libsonnet')(app, useSuffix),
    networkpolicy: (import 'networkpolicy.libsonnet')(app),
    valkeyCluster: (import 'valkey/cluster.libsonnet')(app, valkeySecret.spec.target.name),
    httprouteMain: (import 'httproute/main.libsonnet')(app),
    httprouteRedirect: (import 'httproute/redirect.libsonnet')(app),
    httprouteImgproxy: (import 'httproute/imgproxy.libsonnet')(app),
    scyllaClientCertSa: (import 'scylla/client-cert-sa.libsonnet')(app),
    scyllaClientCertStore: (import 'scylla/client-cert-store.libsonnet')(app),
    scyllaClientCertExternalSecret: (import 'scylla/client-cert-external-secret.libsonnet')(app),
    scyllaClientCertRbac: (import 'scylla/client-cert-rbac.libsonnet')(app),
    rabbitmqCredentialsSecret: (import 'rabbitmq/credentials-secret.libsonnet')(app),
    rabbitmqVhost: (import 'rabbitmq/vhost.libsonnet')(app),
    rabbitmqUser: (import 'rabbitmq/user.libsonnet')(app),
    rabbitmqPermission: (import 'rabbitmq/permission.libsonnet')(app),
  }
