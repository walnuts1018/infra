// Argo CD Agent(spoke)がberryのPrincipalへ自己登録するまでの一式をまとめて返す。
// cluster.jsonnet横の1ファイル(例: argocd-agent-bootstrap.jsonnet)からflatten-resources.libsonnet経由で
// 展開して使うことを想定した公開API。個々の資材の実装は_internal/以下にある。
local rbac = import '_internal/argocd-agent-rbac.libsonnet';
local onepassword = import '_internal/onepassword-bootstrap.libsonnet';
function(cluster, ciliumValues) {
  secretReaderServiceAccount: rbac.serviceAccount(cluster.name),
  secretReaderRole: rbac.role(cluster.name),
  secretReaderRoleBinding: rbac.roleBinding(cluster.name),
  clusterSecretStore: (import '_internal/argocd-agent-cluster-secret-store.libsonnet')(cluster),
  resourcesExternalSecret: (import '_internal/argocd-agent-resources-externalsecret.libsonnet')(cluster),
  clusterResourceSet: (import '_internal/argocd-agent-clusterresourceset.libsonnet')(cluster),
  spokeHelmChartProxy: (import '_internal/argocd-spoke-helmchartproxy.libsonnet')(cluster),
  agentHelmChartProxy: (import '_internal/argocd-agent-helmchartproxy.libsonnet')(cluster),
  ciliumBootstrapHelmChartProxy: (import '_internal/cilium-bootstrap-helmchartproxy.libsonnet')(cluster, ciliumValues),
  onepasswordExternalSecret: onepassword.externalSecret(cluster),
  onepasswordClusterResourceSet: onepassword.clusterResourceSet(cluster),
}
