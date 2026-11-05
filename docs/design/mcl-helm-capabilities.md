# Helm ChartのAPI能力

## 入力の意味

MCLの`helm.render`は`apiVersions`を明示的な入力として受け取り、Chartの`.Capabilities.APIVersions`へ渡す。
空ListはAPI能力を宣言しない値であり、Schema Catalogに登録されているAPIや、利用していないクラスタのAPIを自動追加しない。
Kubernetesの組み込みAPIでも、Chartが`.Capabilities.APIVersions.Has`で照合する場合には、その照合文字列を入力する。

API一覧は、Chartの固定バージョンのテンプレートと、そのアプリで有効にしている機能に対応させる。
Featureを持つアプリではFeatureから一覧を作り、共通Valuesだけのアプリでは使用するAPIをChart設定に明記する。
Kubernetesバージョンの条件だけで適切なAPIを選択できるChartへ、同じ情報を表す巨大なAPI一覧を追加しない。

## 固定アーカイブの確認範囲

`k8s/mcl.lock`に固定されたHTTP ChartとOCI Chartの63アーカイブについて、同梱サブChartも含めて`.Capabilities.APIVersions`の参照を確認した。
表のAPIはテンプレート内の照合候補であり、すべてを有効化する宣言ではない。
無効なサブChart、OpenShift専用分岐、無効なIngress/VPA/監視の分岐のためのAPIは追加しない。
`chart.mcl`などの参照先のバージョンを更新した際は、対応する条件式も確認する。

| 使用モジュール | 固定アーカイブ | テンプレートの照合候補 |
| --- | --- | --- |
| `apps/iwashi-smtp-relay/chart.mcl` | `mail-5.1.0.tgz` | 参照なし |
| `依存Chart` | `memcached-6.14.0.tgz` | `security.openshift.io/v1` |
| `apps/cert-manager/chart.mcl` | `cert-manager-v1.21.2.tgz` | 参照なし |
| `apps/trust-manager/chart.mcl` | `trust-manager-v0.24.0.tgz` | 参照なし |
| `apps/tidb-operator/chart.mcl` | `tidb-operator-v1.6.6.tgz` | 参照なし |
| `apps/iwashi-cortex/chart.mcl` | `cortex-3.3.8.tgz` | `autoscaling/v2/HorizontalPodAutoscaler`、`policy/v1/PodDisruptionBudget`、`security.openshift.io/v1` |
| `apps/moco/chart.mcl` | `moco-0.27.0.tgz` | 参照なし |
| `apps/onepassword-connect/chart.mcl` | `connect-2.3.0.tgz` | `networking.k8s.io/v1beta1` |
| `apps/victoria-metrics/chart.mcl` | `victoria-metrics-cluster-0.50.0.tgz` | `autoscaling.k8s.io/v1` |
| `apps/trivy-operator/chart.mcl` | `trivy-operator-0.36.0.tgz` | 参照なし |
| `_argocd/spoke/chart.mcl`、`_argocd/argocd_components/chart.mcl` | `argo-cd-10.8.2.tgz` | `monitoring.coreos.com/v1`、`policy/v1`、`security.openshift.io/v1` |
| `apps/cloudnative-pg/chart.mcl` | `cloudnative-pg-0.29.0.tgz` | 参照なし |
| `apps/external-secrets/chart.mcl` | `external-secrets-2.10.0.tgz` | `monitoring.coreos.com/v1/ServiceMonitor`、`security.openshift.io/v1` |
| `apps/grafana/chart.mcl` | `grafana-13.2.5.tgz` | `autoscaling.k8s.io/v1/VerticalPodAutoscaler`、`autoscaling/v2`、`policy/v1beta1/PodSecurityPolicy` |
| `apps/caretta/chart.mcl` | `caretta-0.0.16.tgz` | `networking.k8s.io/v1`、`networking.k8s.io/v1beta1`、`policy/v1/PodDisruptionBudget`、`policy/v1beta1`、`policy/v1beta1/PodSecurityPolicy`、`rbac.authorization.k8s.io/v1`、`security.openshift.io/v1` |
| `apps/influxdb/chart.mcl` | `influxdb2-2.1.2.tgz` | `networking.k8s.io/v1/Ingress`、`policy/v1` |
| `apps/ephemeral-storage-metrics/main.mcl` | `k8s-ephemeral-storage-metrics-1.21.3.tgz` | 参照なし |
| `apps/rabbitmq-cluster-operator/chart.mcl` | `rabbitmq-cluster-operator-0.4.2.tgz` | 参照なし |
| `apps/rabbitmq-topology-operator/chart.mcl` | `rabbitmq-topology-operator-0.4.1.tgz` | 参照なし |
| `apps/cluster-api-operator/chart.mcl` | `cluster-api-operator-0.26.0.tgz` | 参照なし |
| `apps/descheduler/chart.mcl` | `descheduler-0.36.0.tgz` | 参照なし |
| `apps/external-dns-cloudflare/main.mcl`、`apps/external-dns-coredns/chart.mcl` | `external-dns-1.21.1.tgz` | 参照なし |
| `apps/metrics-server/chart.mcl` | `metrics-server-3.14.0.tgz` | `policy/v1` |
| `apps/vertical-pod-autoscaler/chart.mcl` | `vertical-pod-autoscaler-0.12.0.tgz` | 参照なし |
| `apps/longhorn/chart.mcl` | `longhorn-1.12.1.tgz` | PSP検査のコメントのみ。追加APIなし。 |
| `apps/opentelemetry-operator/chart.mcl` | `opentelemetry-operator-0.122.0.tgz` | `autoscaling.k8s.io/v1` |
| `apps/opencost/chart.mcl` | `opencost-2.5.31.tgz` | `networking.k8s.io/v1`、`networking.k8s.io/v1beta1`、`route.openshift.io/v1/Route` |
| `apps/kube-state-metrics/chart.mcl` | `kube-state-metrics-8.4.2.tgz` | `autoscaling.k8s.io/v1` |
| `apps/blackbox-exporter/main.mcl`、`apps/iwashi-blackbox/chart.mcl` | `prometheus-blackbox-exporter-11.18.0.tgz` | `autoscaling.k8s.io/v1` |
| `apps/prometheus-node-exporter/chart.mcl` | `prometheus-node-exporter-4.56.3.tgz` | `autoscaling.k8s.io/v1` |
| `apps/prometheus-operator-crds/chart.mcl` | `prometheus-operator-crds-31.0.1.tgz` | 参照なし |
| `apps/smartctl-exporter/chart.mcl` | `prometheus-smartctl-exporter-0.17.1.tgz` | 参照なし |
| `apps/snmp-exporter/chart.mcl` | `prometheus-snmp-exporter-9.17.1.tgz` | 参照なし |
| `apps/qdrant/chart.mcl` | `qdrant-1.19.1.tgz` | 参照なし |
| `apps/seaweedfs-operator/chart.mcl` | `seaweedfs-operator-0.1.40.tgz` | 参照なし |
| `apps/radar/chart.mcl` | `radar-1.12.2.tgz` | 参照なし |
| `apps/kafka-operator/chart.mcl` | `strimzi-kafka-operator-helm-3-chart-1.2.0.tgz` | 参照なし |
| `apps/topolvm/chart.mcl` | `topolvm-17.2.0.tgz` | 参照なし |
| `apps/valkey-operator/chart.mcl` | `valkey-operator-0.6.0.tgz` | 参照なし |
| `apps/velero/chart.mcl` | `velero-12.1.0.tgz` | `monitoring.coreos.com/v1`、`policy/v1/PodDisruptionBudget` |
| `apps/zitadel/chart.mcl` | `zitadel-10.0.6.tgz` | `security.openshift.io/v1` |
| `apps/cilium/chart.mcl` | `cilium-1.20.2.tgz` | `gateway.networking.k8s.io/v1/GatewayClass`、`monitoring.coreos.com/v1` |
| `apps/eck-operator/chart.mcl` | `eck-operator-3.5.0.tgz` | 参照なし |
| `apps/nvidia-gpu-operator/chart.mcl` | `gpu-operator-v26.7.0.tgz` | `resource.k8s.io/v1/DeviceClass`、`resource.k8s.io/v1beta1/DeviceClass`、`resource.k8s.io/v1beta2/DeviceClass` |
| `apps/keda/chart.mcl` | `keda-2.20.2.tgz` | 参照なし |
| `apps/keda-http-addon/chart.mcl` | `keda-add-ons-http-0.15.0.tgz` | 参照なし |
| `apps/scylla-manager/app.mcl` | `scylla-manager-v1.21.1.tgz` | 参照なし |
| `apps/scylla-operator/chart.mcl` | `scylla-operator-v1.21.1.tgz` | 参照なし |
| `apps/scylla-cluster/app.mcl` | `scylla-v1.21.1.tgz` | 参照なし |
| `apps/reloader/chart.mcl` | `reloader-2.2.17.tgz` | `apps.openshift.io/v1`、`argoproj.io/v1alpha1`、`autoscaling.k8s.io/v1`、`monitoring.coreos.com/v1`、`rbac.authorization.k8s.io/v1` |
| `apps/envoy-gateway/chart.mcl` | `docker.io/envoyproxy/gateway-helm@1.6.1` | 参照なし |
| `apps/actions-runner-controller/chart.mcl` | `ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller@0.14.2` | 参照なし |
| `_argocd/agent/agent/chart.mcl` | `ghcr.io/argoproj-labs/argocd-agent/argocd-agent-agent@0.2.7` | 参照なし |
| `_argocd/agent/principal/chart.mcl` | `ghcr.io/argoproj-labs/argocd-agent/argocd-agent-principal@0.3.3` | 参照なし |
| `apps/clickhouse-operator/chart.mcl` | `ghcr.io/clickhouse/clickhouse-operator-helm@0.0.6` | 参照なし |
| `apps/coder/chart.mcl` | `ghcr.io/coder/chart/coder@2.36.5` | 参照なし |
| `apps/gha-cache-server/chart.mcl` | `ghcr.io/falcondev-oss/charts/github-actions-cache-server@1.1.3` | 参照なし |
| `apps/loki/chart.mcl` | `ghcr.io/grafana-community/helm-charts/loki@13.2.0` | `gateway.networking.k8s.io/v1`、`gateway.networking.k8s.io/v1beta1`、`monitoring.coreos.com/v1/PrometheusRule`、`monitoring.coreos.com/v1/ServiceMonitor`、`policy/v1beta1/PodDisruptionBudget`、`security.openshift.io/v1` |
| `apps/tempo/chart.mcl` | `ghcr.io/grafana-community/helm-charts/tempo-distributed@2.26.2` | `gateway.networking.k8s.io/v1`、`gateway.networking.k8s.io/v1beta1`、`security.openshift.io/v1` |
| `apps/pyroscope/chart.mcl` | `ghcr.io/grafana/helm-charts/pyroscope@2.0.1` | `autoscaling.k8s.io/v1`、`networking.k8s.io/v1`、`networking.k8s.io/v1beta1`、`policy/v1`、`security.openshift.io/v1` |
| `apps/shumoku/chart.mcl` | `ghcr.io/konoe-akitoshi/charts/shumoku@0.1.5` | 参照なし |
| `apps/netbox/chart.mcl` | `ghcr.io/netbox-community/netbox-chart/netbox@8.3.18` | `security.openshift.io/v1` |
| `依存Chart` | `registry-1.docker.io/bitnamicharts/common@2.18.0` | `security.openshift.io/v1` |

## CiliumのFeature

Ciliumの監視Featureは`monitoring.coreos.com/v1`を宣言する。
監視APIの宣言はChartの監視有効時の検証に対応する。
Gateway APIのFeatureでは`gatewayClass.create: false`を指定しているため、GatewayClass自動作成用の能力を宣言しない。
自動作成を有効にする仕様へ変更する際は、Chartの`gateway.networking.k8s.io/v1/GatewayClass`照合と対応させる。
Schema CatalogへCiliumやGateway APIのSchemaを追加したことだけを理由に、両方を常に有効化しない。

## 生成結果の確認

Chart能力の変更で新たなリソースが出力される場合は、対応するValuesまたはFeatureが既に有効であり、従来は能力宣言不足で生成されていなかったことを確認する。
構造整理による出力差分と、この不足を修正する出力差分を分けて確認する。
実クラスタのAPI存在確認と、ArgoCDによる依存リソースの作成順序は、このオフライン入力契約の検証範囲に含めない。

## CRDの所有者とSchema配布物

Gateway APIの共有CRDは`apps/gateway-api-crds`が所有する。
Envoy Gateway Chartに同梱された古いGateway API CRDを重複配置せず、Envoy Gatewayアプリは`gateway.envoyproxy.io`のCRDとコントローラーのリソースを所有する。
Envoy側の選択関数はGateway APIの2グループだけを対象にし、Envoy固有のCRDやそれ以外のリソースを削除しない。
Gateway APIのCatalogは、配置アプリと同じGit revisionのstandardディレクトリから取得する。
同じGVKでもexperimentalとstandardではSchemaが異なるため、異なるchannelのSchemaを組み合わせない。

ECKのCatalogはGitの型定義から生成されたSchemaではなく、Operator Chartと一致する公式配布の`crds.yaml`を使用する。
ECK 3.5.0では同じリリースのGitリソースと配布Chartの間でも、ElasticsearchのPod templateのSchemaと提供Version一覧が異なっていた。
公式配布ManifestとChartの該当Schemaが一致することを確認し、Catalogを配布Manifestへ揃えた。
配布URLのバージョンは既存のRenovate custom managerと同じ方式で検出し、Operatorのバージョン更新時にも照合できるようにする。
CRD衝突検査や未知フィールド検査は維持する。

## 最終評価

公開済みMCL v0.3.32でinfra内のMCLアプリ配置135件を評価し、135件が成功した。
変更前の開発評価と比較した結果、129件のManifestは同一で、6件の配置に差分があった。
差分はCiliumの2配置で共有Secret namespaceを維持した変更、Cilium Hubble OAuth2 ProxyとFitbit Managerで共有Gatewayのnamespaceを参照する変更、Coder WorkspacesのNetworkPolicyとServiceAccountを正しいResourceとして出力する修正、SNMP Exporterへ実行時設定を渡す修正に限定された。
Chart capabilityの不足によって新しいResourceを追加する差分は確認されなかった。
