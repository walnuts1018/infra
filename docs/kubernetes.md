# Kubernetes

Kubernetes クラスタに適用される Manifest 群です。

## ディレクトリ構成

- `cluster.mcl`: アプリ配置とCluster API入口が使用するクラスタ型。
- `clusters/<cluster>/cluster.json`: クラスタ共通情報とCluster APIの構築値。
- `clusters/<cluster>/*.mcl`: クラスタ構築Manifest。
- `apps/<app>/app.json`: 配置するクラスタ、namespace、配置ごとのFeature・Settings。
- `apps/<app>/*.mcl`: 型付き入力からアプリケーションManifestを生成するMCLソース。
- `_argocd/applications`: アプリ配置を自動発見するApplicationSet、Agentクラスタ生成関数、共通Go Template。
- `_argocd/cmp`: MCL CMPの実装と入力契約。
- `namespaces`: Namespace Manifest。
- 初期構築と運用
  - [初期構築](init/berry.md)
  - [クラスター情報](init/)
  - [運用](operations/)

## アプリ配置とMCL入力

ApplicationSetは`k8s/apps/*/app.json`を読み、`clusters`に明示されたクラスタだけにApplicationを生成します。アプリを追加するときは、そのアプリの`app.json`とMCLソースを追加します。`app.json`トップレベルの`namespace`は各配置の既定値です。配置の`clusters.<name>.namespace`を指定した場合はその値を優先し、解決したnamespaceをApplicationの`destination.namespace`とMCLの`namespace`入力へ同じ値で渡します。`app.json`経由の全MCL入口は`param namespace: String`を宣言し、Cluster-scopedリソースだけを生成する場合も入力を受け取りますが、そのリソースにはnamespaceを設定しません。

クラスタ情報は`k8s/clusters/<cluster>/cluster.json`を正本とします。アプリ入口には`name`、`namespace`、`kubernetesVersion`だけを射影した`Cluster`を渡し、Helm Chartの`kubeVersion`には`cluster.kubernetesVersion`を使います。Cluster API入口にはTalosバージョンとマシン台数を含む6フィールドの`ClusterAPIConfig`を渡します。`clusterApiManaged`が文字列`"true"`のクラスタだけをCluster API ApplicationSetの対象とし、将来のCMPプラグインも同じ値を検証する契約です。Berryの`kubernetesVersion`は既存のHelm設定`1.36.4`を引き継いだ値で、実クラスタから取得した値ではありません。Manifestの差分はFeatureとSettingsで表し、汎用Profileやクラスタ名による条件分岐は使いません。

ApplicationSetの共通Go Templateは`MCL_CLUSTER_NAME`、`MCL_NAMESPACE`、`MCL_CLUSTER_INPUT=application`、選択された配置設定のJSONをCMPへ渡します。CMPはcluster定義からアプリ用の3フィールドを射影し、配置設定を含む一時JSONを作成して`mcl fetch --locked`と`mcl render --parameter-file`へ渡します。両コマンドには同じパラメータファイルと、対象clusterの`kubernetesVersion`を`--kubernetes-version`で指定します。`MCL_NAMESPACE`はnamespace入力として別に渡し、JSONパラメータへ含めません。`app.json`経由でない入口では`MCL_NAMESPACE`を省略できます。Cluster API ApplicationSetは`MCL_CLUSTER_INPUT=clusterAPI`を指定し、Cluster API用の6フィールドを射影します。このモードでは`MCL_NAMESPACE`を拒否し、出力namespaceを`cluster.namespace`に限定します。JSON値をシェルコードとして展開しません。この契約ではCMP実行環境に`jq`が必要です。

`app.json`と`cluster.json`はArgo CD Git File Generatorが読む厳密なJSONです。MCLパラメータファイルも厳密なJSONで、解決済みの一時入力はGitへコミットしません。`MCL_DEPLOYMENT_JSON`は選択した配置のFeatureやSettingsを運び、`cluster`と`namespace`は予約キーとして拒否します。CMPプラグインは未知の入力モード、空namespace、Cluster API必須値の欠落、Cluster API管理対象外のクラスタを拒否する仕様です。

`k8s/apps/envoy-gateway-class/gateway.mcl`は共有Gatewayの名前と所有namespaceを定義します。MCLで生成するHTTPRouteの`parentRefs`、Chart Valuesの`parentRefs`、共有Gateway namespaceを選択するNetworkPolicyは`gateway.namespace`を参照します。Route自身の`metadata.namespace`には引き続きアプリnamespaceを指定します。

KurumiとBiscuitは同じAgentクラスタ構成を`k8s/_argocd/applications/agent-cluster.mcl`から生成します。クラスタ別ファイルにはクラスタ名、Project、destination、Namespace Manifestのパスだけを記載します。BerryはPrincipalの役割を持つため、この関数の対象外です。

Helm Chartの`.Capabilities.APIVersions.Has`条件とMCLから渡す`apiVersions`の対応は[Helm Capabilities一覧](design/mcl-helm-capabilities.md)に記録します。CRD Schema Catalogへの登録は、対象クラスタでAPIが利用可能である根拠にしません。

## MCLのResource合成

複数の設定値を受け取る関数は、Akvoradoの`appContainer(name = ..., args = ..., resources = ...)`のように名前付き引数で呼び出します。省略可能な設定には関数引数のデフォルト値を定義し、空Listを渡すためだけの変数を作りません。大きな設定は型付きレコードとして分離します。

Resource Listは通常の要素と`...items`による明示的な展開で合成します。単一Resourceを1要素Listに包む関数は不要です。単純な射影には`for`を使い、各入力が複数Resourceを返す場合は`lists.flatMap()`で1段だけ展開します。SeaweedFSのS3設定ではClientごとのIdentity、Policy、Binding、Credentialsをまとめて生成します。複数Resourceの出力には`emit each`を使います。

トップレベル関数の宣言順序は呼び出し順序に依存しないため、PostgreSQLのように公開する`resources()`を内部の補助関数より前へ配置できます。通常の`let`は宣言順に評価します。ラベルやContainerなど、独立して出力しない値はMapを返し、参照可能な識別情報が必要なResourceには`node:`を使います。

Cluster APIのハッシュ入力には共有の`MachineIdentity`型を使います。`Map<String, Any>`を返す関数では呼び出し元へフィールド型を伝えられないため、ControlPlaneConfigやWorkerConfigへ値を追加する前に、identityの4フィールドをレコード型で確定します。

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

### 将来のCMPとLifecycle

将来のCMPはMCLのBundle全体を受け取り、各ArtifactのLifecycleをArgoCDの同期順序とHookへ変換する。
標準CLIの`mcl render`は既定でmainフェーズだけを出力するため、この出力だけをデプロイ用の完全なManifestとして扱わない。
`_argocd/cmp/_configs/render-mcl.sh`は入力解決とmain出力の参照実装であり、Lifecycle変換は将来のプラグインの責務とする。

プラグインの出力には次の規則を適用する。

- bootstrapのCRDは永続的な管理リソースとして出力し、通常リソースより前のSync waveへ配置する。
- mainのリソースは通常の管理リソースとして出力する。
- Hook用ArtifactはLifecycleを保持し、ArgoCDへ対応するHook種別、実行順序、削除条件を明示して出力する。
- 一つのArtifactが複数のイベントを持つ場合、同じリソースの重複出力や通常リソースとの所有権の衝突を検出する。
- 対応できないLifecycleを黙って省略せず、プラグインが設定エラーとして報告する。

この変換はArgoCDアダプターへ実装し、MCLの汎用評価器や各アプリへ暗黙の全体書き換えを追加しない。
ローカルの評価ではBundle全体の検証と、mainまたはbootstrapなど指定フェーズの出力を区別する。
