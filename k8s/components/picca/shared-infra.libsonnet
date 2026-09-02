function(app, useSuffix=true)
  local valkeySecret = (import '_internal/valkey/external-secret.libsonnet')(app, useSuffix);
  local rabbitmqSecret = (import '_internal/rabbitmq/external-secret.libsonnet')(app, useSuffix);
  {
    sa: (import '_internal/sa.libsonnet')(app),
    postgresSecret: (import '_internal/postgres/external-secret.libsonnet')(app, useSuffix),
    scyllaSecret: (import '_internal/scylla/external-secret.libsonnet')(app, useSuffix),
    valkeySecret: valkeySecret,
    oidcSecret: (import '_internal/oidc/external-secret.libsonnet')(app, useSuffix),
    rabbitmqSecret: rabbitmqSecret,
    graphqlSigningSecret: (import '_internal/common/graphql-signing-secret.libsonnet')(app, useSuffix),
    imgproxySecret: (import '_internal/imgproxy/external-secret.libsonnet')(app, useSuffix),

    configmapPlans: (import '_internal/common/plans/configmap.libsonnet')(app, useSuffix),
    configmapScylladbCa: (import '_internal/scylla/configmap-ca.libsonnet')(app, useSuffix),
    networkpolicy: (import '_internal/networkpolicy.libsonnet')(app),
    valkeyCluster: (import '_internal/valkey/cluster.libsonnet')(app, valkeySecret.spec.target.name),
    httprouteMain: (import '_internal/httproute/main.libsonnet')(app),
    httprouteRedirect: (import '_internal/httproute/redirect.libsonnet')(app),
    httprouteImgproxy: (import '_internal/httproute/imgproxy.libsonnet')(app),
    scyllaClientCertSa: (import '_internal/scylla/client-cert-sa.libsonnet')(app),
    scyllaClientCertStore: (import '_internal/scylla/client-cert-store.libsonnet')(app),
    scyllaClientCertExternalSecret: (import '_internal/scylla/client-cert-external-secret.libsonnet')(app),
    scyllaClientCertRbac: (import '_internal/scylla/client-cert-rbac.libsonnet')(app),
    rabbitmqCredentialsSecret: (import '_internal/rabbitmq/credentials-secret.libsonnet')(app),
    rabbitmqVhost: (import '_internal/rabbitmq/vhost.libsonnet')(app),
    rabbitmqUser: (import '_internal/rabbitmq/user.libsonnet')(app),
    rabbitmqPermission: (import '_internal/rabbitmq/permission.libsonnet')(app),
  }
