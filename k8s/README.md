# Kubernetes

Kubernetes クラスタに適用される Manifest 群です。

## ディレクトリ構成

- `_argocd`: ArgoCD 用
  - `applications`: ArgoCD Application リソース
    - `[<cluster>]`:
      - `apps.yaml`: ApplicationSet / `apps`ディレクトリの`app.json5`を見てApplicationを生成
      - `argodcd.yaml`: `argocd_components`を見るApplication
      - `namespaces.yaml`: `namespace` を見る Application
  - `argocd_components`: ArgoCD 用のコンポーネント
    - `appproject.jsonnet`: ArgoCD AppProject
    - `externalsecret.jsonnet`: ArgoCD用のSecret
    - `helm.jsonnet`: ArgoCD
    - `notification-externalsecret.jsonnet`: Secret
    - `values.yaml`: ArgoCDの Helm values
  - `clusters`: クラスタ固有の設定
- `apps`: アプリケーションごとの Manifest。
- `components`: Jsonnet Component
  - `application.libsonnet`: ArgoCD Application 用テンプレート
  - `configmap.libsonnet`: ConfigMap 用テンプレート / 自動でPrefixを付与
  - `container.libsonnet`: コンテナ用テンプレート / SecurityContextなどを自動付与
  - `external-secret.libsonnet`: External Secret 用テンプレート / 自動でPrefixを付与
  - `helm.libsonnet`: Helm 用のArgoCD Applicationテンプレート
  - `labels.libsonnet`: ラベル生成用テンプレート
  - `oauth2-proxy/`: OAuth2 Proxy 用コンポーネント
- `init`: [./init](./init)
- `namespaces`: namespace たち
- `utils`: ユーティリティlibsonnet

## クラスタ構成

| HostName | Model                        | CPU                                     | Memory    | Disk                                              | OS                             | ControlPlane |
| :------- | :--------------------------- | :-------------------------------------- | :-------- | :-------------------------------------------------| :----------------------------- | :----------- |
| cake     | HP ProDesk 400 G4 DM (Japan) | Intel Core i5-8500T Processor (6 cores) | 64GB      | KIOXIA-EXCERIA G2 (1TB), CT1000MX500SSD1/JP (1TB) | Ubuntu 24.04.3 LTS             | ○            |
| hotate   | TRIGKEY Key-N100             | Intel Processor N100 (4 cores)          | 16GB      | KIOXIA-EXCERIA G3 (1TB)                           | Ubuntu 24.04.3 LTS             | ○            |
| cheese   | Raspberry Pi 4B              | BCM2835 (4 cores)                       | 4GB       | CSSD-S6O240NCG1Q (240GB)                          | Debian GNU/Linux 12            | ○            |
| donut    | Raspberry Pi 4B              | BCM2835 (4 cores)                       | 2GB       | Apacer AS340 (120GB)                              | Debian GNU/Linux 12            |              |

## 稼働サービス

### システム・インフラ

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
- **pomerium-controller**
- **pomerium-global**
- **priorities**: Pod 優先度クラスの設定
- **redis-operator**
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
- **minio-biscuit**
- **minio-biscuit-backup**
- **minio-biscuit-backup-trigger**
- **minio-default-backup**
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
- **picca-ai-prototype**
- **picca-ai-prototype-qdrant**
- **prfexample**
- **stalwart**
- **ubuntu-test**: テスト・デバッグ用のコンテナ
- **walnuk**: 短縮URLサービス <https://waln.uk>
- **walnuts-dev**: <https://walnuts.dev>
- **warrior**
- **zitadel**: 自宅IdP / Walnuts.devの各サービスにSSOを提供
