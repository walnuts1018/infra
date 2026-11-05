# Kubernetes

Kubernetes クラスタに適用される Manifest 群です。

## ディレクトリ構成

- `clusters/<cluster>/cluster.json`: Kubernetesバージョンやクラスタ識別名などのクラスタ情報。
- `apps/<app>/app.json`: 配置するクラスタと、配置ごとのFeature・Settings。
- `apps/<app>/*.mcl`: 型付き入力からアプリケーションManifestを生成するMCLソース。
- `_argocd/applications`: アプリ配置を自動発見するApplicationSetと共通Go Template。
- `_argocd/cmp`: MCL CMPの実装と入力契約。
- `namespaces`: Namespace Manifest。
- 初期構築と運用
  - [初期構築](init/berry.md)
  - [クラスター情報](init/)
  - [運用](operations/)
- `namespaces`: namespace たち
- `utils`: ユーティリティlibsonnet

## アプリ配置とMCL入力

ApplicationSetは`k8s/apps/*/app.json`を読み、`clusters`に明示されたクラスタだけにApplicationを生成します。アプリを追加するときは、そのアプリの`app.json`とMCLソースだけを更新します。Applicationのnamespaceはアプリ共通の`app.json`で指定し、配置ごとの上書きは行いません。

クラスタ情報は`k8s/clusters/<cluster>/cluster.json`を正本とします。`clusterApiManaged`が`"true"`のクラスタだけがCluster API用ApplicationSetの対象です。Berryの`kubernetesVersion`は既存のHelm設定`1.36.4`を引き継いだ値で、実クラスタから取得した値ではありません。アプリのMCL入口は共通の`Cluster`型を受け取り、Helm Chartの`kubeVersion`には`cluster.kubernetesVersion`を渡します。Manifestの差分はFeature、Settings、意味のあるProfileで表し、クラスタ名による条件分岐は使いません。

ApplicationSetの共通Go Templateは`MCL_CLUSTER_NAME`と選択された配置設定のJSONをCMPへ渡します。CMPはクラスタ定義から`name`、`namespace`、`kubernetesVersion`を読み、配置設定と合わせた一時JSONファイルを作成して`mcl render --parameter-file`へ渡します。JSON値をシェル引数のコードとして展開しません。この契約ではCMP実行環境に`jq`が必要です。

`app.json`と`cluster.json`はArgo CD Git File Generatorが読む厳密なJSONです。MCLパラメータファイルも厳密なJSONで、解決済みの一時入力はGitへコミットしません。

## Private MCL依存

MCLがlockと依存キャッシュにないGitHub Release assetを取得する場合、Argo CD CMP実行環境に対象リポジトリを読み取れる`GITHUB_TOKEN`を設定します。MCLはGitHub APIでRelease情報とassetを取得し、assetのダウンロード先へリダイレクトするときに`Authorization`ヘッダーを削除します。Token値をManifestやGit管理ファイルへ記載しません。

## クラスタ構成

### berry クラスタ

### kurumi クラスタ

| HostName | Model                         | CPU                            | Memory | Disk                                              | OS         | ControlPlane |
| :------- | :---------------------------- | :------------------------------| :----- | :------------------------------------------------ | :--------- | :--- |
| cake     | ASRock B660M Phantom Gaming 4 | Intel (12 threads)              | 48GB   | 512GB SSD(OS), KIOXIA EXCERIA G2 1TB, CT1000MX500SSD1 1TB | Talos v1.14 | ○           |
| hotate   | TRIGKEY Key-N100             | Intel Processor N100 (4 cores)          | 32GB   | KIOXIA EXCERIA PLUS G3                            | Talos v1.14 | ○           |
| lemon    | Lenovo IdeaPad 5 15ITL05      | Intel Tiger Lake (8 threads)    | 16GB   | Samsung MZALQ512HALU 512GB                        | Talos v1.14 | ○           |
| rusk     | HP ProLiant DL120 Gen9        | Intel (20 threads)              | 32GB   | HP Smart Array 論理ドライブ(OS/TopoLVM)           | Talos v1.14 |              |

### biscuit クラスタ

## 稼働サービス

### システム・インフラ

- **actions-runner-controller**: GitHub Actions Runner Controller (ARC) Operator
- **actions-runners**: GitHub Actions Self-hosted Runner Scale Sets (Small / Large)
- **api-server-proxy**
- **api-server-service-account-issuer-discovery**
- **argocd-proxy**
- **cert-manager**
- **cilium**
- **cilium-hubble-oauth2-proxy**: Cilium Hubble UI の OAuth2 Proxy
- **cilium-ipaddress**: Cilium LB 用 の IP アドレス管理
- **cloudflare-tunnel**: Cloudflare Tunnel Resource
- **cloudflare-tunnel-operator**: Cloudflare TunnelをCustom Resourceから自動作成
- **cluster-api-operator**
- **clusterissuer**
- **coredns**
- **descheduler**
- **envoy-gateway**
- **envoy-gateway-class**
- **external-dns**
- **external-secrets**
- **external-secrets-store**: External Secrets のOnePassword プロバイダー
- **eck-operator**: Elastic 公式の Elastic Cloud on Kubernetes Operator
- **external-snapshotter**
- **ghcr-login-secret**
- **kube-virt**
- **local-path-provisioner**
- **longhorn**
- **longhorn-backup**: Longhorn バックアップ設定
- **longhorn-backup-validate**
- **longhorn-backup-validate-template**
- **longhorn-oauth2-proxy**: Longhorn UI の OAuth2 Proxy
- **mcs-api**
- **nvidia-gpu-operator**
- **priorities**: Pod 優先度クラスの設定
- **renovate**: Self-hosted Renovate
- **tailscale**
- **trivy-operator**
- **trust-manager**
- **velero**

### モニタリング・オブザーバビリティ

- **blackbox-exporter**
- **caretta**
- **ephemeral-storage-metrics**
- **grafana**
- **kube-state-metrics**
- **loki**
- **metrics-server**
- **opencost**
- **opentelemetry-collectors**
- **opentelemetry-instrumentations**
- **opentelemetry-operator**
- **prometheus-node-exporter**
- **prometheus-operator-crds**
- **pyroscope**
- **smartctl-exporter**
- **snmp-exporter**
- **tempo**
- **victoria-metrics**

### データベース・ストレージ

- **cloudnative-pg**: PostgreSQL オペレーター
- **cloudnative-pg-barman-cloud-plugin**: PostgreSQL バックアッププラグイン
- **cloudnative-pg-image-catalog**
- **influxdb**: 時系列データベース
- **seaweedfs-biscuit**
- **seaweedfs-default-backup**
- **moco**: MySQL オペレーター
- **postgresql-default**: 複数サービスで共用の PostgreSQL インスタンス
- **rabbitmq-cluster-operator**
- **rabbitmq-default**
- **rabbitmq-topology-operator**
- **samba**
- **scylla-cluster**
- **scylla-manager**
- **scylla-node-config**
- **scylla-operator**
- **seaweedfs-default**
- **seaweedfs-operator**
- **stalwart-search**: Stalwart の全文検索用 Elasticsearch クラスター

### アプリケーション

- **affine**: ノート
- **esp32-thermohygrometer-exporter**: ESP32 の温湿度データを OpenTelemetry にエクスポート
- **fitbit-manager**: Fitbitのデータを収集し、InfluxDBに保存する /<https://walnuts.dev> に心拍数データを提供
- **github-readme-stats**
- **http-dump**: HTTP テスト用サイト / <https://httptest.walnuts.dev>
- **ipu**: IPU Doc
- **komga**: 電子書籍管理 / <https://komga.org/>
- **machine-status-api**: GPIOで物理サーバーを起動するためのAPIサーバー
- **misskey**: <https://misskey.walnuts.dev>
- **mpeg-dash-encoder**: MPEG-DASH のエンコードを行うAPI サーバー
- **mucaron**: 音楽アプリ
- **oekaki-dengon-game**: NF2023で開催したお絵描き伝言ゲーム / <https://oekaki.walnuts.dev/public>
- **openchokin**: 家計簿アプリ
- **prfexample**
- **stalwart**
- **ubuntu-test**: テスト・デバッグ用のコンテナ
- **walnuk**: 短縮URLサービス <https://waln.uk>
- **walnuts-dev**: <https://walnuts.dev>
- **warrior**
- **zitadel**: 自宅IdP / Walnuts.devの各サービスにSSOを提供
