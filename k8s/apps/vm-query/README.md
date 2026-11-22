# VictoriaMetricsの保持期間別ストレージ

OpenTelemetry Collectorから受信したすべてのメトリクスはvmagentを経由して保存する。Grafana、OpenCost、KEDAは共通のvm-queryへ問い合わせる。

| Argo CDアプリケーション | コンポーネント | 設定 |
| --- | --- | --- |
| `vmagent` | vmagent | `retention="long"`の系列のみlongへ送信し、残りをshortへ送信 |
| `vm-short` | vminsert、vmstorage | 30日、TopoLVM HDD |
| `vm-long` | vminsert、vmstorage | 100年、TopoLVM HDD |
| `vm-query` | vmselect | 両方のストレージグループを横断検索 |

## データの経路

- 収集: OpenTelemetry Collector → `vmagent-victoria-metrics-agent:8429/api/v1/write`
- 通常保存: vmagent → `vm-short-victoria-metrics-cluster-vminsert:8480` → vmstorage（30日）
- 長期保存: vmagent → `vm-long-victoria-metrics-cluster-vminsert:8480` → vmstorage（100年）
- 検索: Grafanaなど → `vm-query-victoria-metrics-cluster-vmselect:8481/select/0/prometheus` → 両vmstorage

各系列をshortとlongの両方に保存すると必要なディスク容量が増えるため、vmagentの`remoteWrite[].urlRelabelConfig`で送信先を排他的に決定する。

## 永続保存対象

メトリクス名とラベルを含む系列を指定して保存先を選択する。現在は`retention="long"`ラベルが付いた系列のみlongへ保存し、それ以外はすべてshortへ保存する。**明示的にラベルを付けない限り、長期保存は行わない。**

長期保存したいメトリクスは、OpenTelemetry Collectorの変換設定、Prometheus receiverの`metric_relabel_configs`、または送信元で`retention="long"`ラベルを付ける。条件を変更する場合は`k8s/apps/vmagent/values.yaml`の2つの`urlRelabelConfig`を対で変更する。

VictoriaMetrics OSSは厳密な無期限Retentionを提供しないため、longは公式が案内している`100y`を使用する。100年間のディスク容量を予約する設定ではない。longのPVC使用量は別途監視する必要がある。

## Helm

4つのアプリケーションはVictoriaMetricsの公式Chartを使う。Chartのバージョンはそれぞれの`helm.jsonnet`で指定する。各リリースのValuesにネットワークポリシーとリソース設定をまとめるため、リリース専用の独自Controllerや追加の手書きDeploymentは不要。

公式資料: https://docs.victoriametrics.com/guides/guide-vmcluster-multiple-retention-setup/
