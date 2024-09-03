# Kubernetes

Kubernetes クラスタに適用される Manifest 群です。

## ディレクトリ構成

- `_flux`: flux 用
  - `<クラスタ名>`
    - `flux-system`: flux 用の色々
    - `<appName>.yaml`: アプリごとの kustomize(kustomize.toolkit.fluxcd.io/v1beta2)。`apps`内のそれぞれのフォルダを`path`で指定している
- `apps`: アプリケーションごとの Manifest。
- `archives`: 現在はデプロイされていない apps の墓場
- `components`: kustomize Component
  - `helm`: helm 用の設定テンプレート
  - `image-policy`: fluxcd image automation の設定テンプレート
- `image-update`: image automation の Manifest

  - `<app名>`:　アプリごとの`ImageRepository`や`ImagePolicy`
  - `imageupdateautomation.yaml`: 実際にリポジトリの更新を行う`ImageUpdateAutomation`さん
  - `externalsecret.yaml`: GitHub Token

- `init`: インストールコマンドとインストール時に使う Manifest ⇒ [./init/readme.md](./init/readme.md)
- `namespaces`: namespace たち

## クラスタ構成

| HostName | Model                        | CPU                             | Memory    | Disk                                     | OS                  | ControlPlane |
| :------- | :--------------------------- | :------------------------------ | :-------- | :--------------------------------------- | :------------------ | :----------- |
| cake     | HP ProDesk 400 G4 DM (Japan) | Intel i5-8500T (6 cores)        | 64GB      | KIOXIA-EXCERIA G2 SSD 1TB                | Ubuntu 22.04        | ○            |
| cheese   | Raspberry Pi 4B              | BCM2835 (4 cores)               | 4GB       | CSSD-S6O240NCG1Q 240GB                   | Debian GNU/Linux 11 |              |
| donut    | Raspberry Pi 4B              | BCM2835 (4 cores)               | 2GB       | Apacer AS340 120GB                       | Debian GNU/Linux 11 |              |
| hotate   | QEMU VM                      | Host(Intel i5-12400f) (4 cores) | 2GB / 8GB | Virtual Disk 128GB (Crucial P5 Plus 1TB) | Ubuntu22.04         |              |

## 稼働サービス

### システム

- external-dns: Ingress リソースから自動的に外部 DNS サーバーに登録してくれるマン。Cloudflare Tunnel に登録できるように修正を加えています。
- external-secrets: Vault などの外部サービスからデータを読み込み、Secret を作成してくれるマン。
- flannel: CNI です。
- ingress-nginx: Nginx を L7LB として利用した Ingress Controller
- longhorn: Kubernetes 用の分散ストレージシステム。Kubernetes の PersistentVolume として利用できる。
- metallb: LoadBalancer

### サービス

- keycloak: OIDC Provider。ユーザー管理と IdP をやってくれる。これ一つで色々なサービスに Single Sign On できる。walnuts.dev を支える認証システム。
- grafana: メトリクスの可視化ツール。
- influxdb: メトリクスの収集と保存を行う DB。
- krakend: API Gateway。外部からの API アクセスを制御。
- kube-state-metrics: Kubernetes の状態をメトリクスとして提供する。
- metrics-server: Kubernetes のメトリクスを提供する。
- node-exporter: ノードのメトリクスを提供する。
- postgresql: PostgreSQL
- redis: Redis
- samba: Samba
- tailscale: Tailscale Net に、192.168.0.0/24 を公開
- vault: シークレット管理システム。Vault に保存されたシークレットは、external-secrets によって Secret として Kubernetes に登録される。
- victoria-metrics: Prometheus 互換のメトリクス収集サーバー。

### アプリ

- backup-manager: バックアップを統一的に管理するアプリ。
- blog: <https://blog.walnuts.dev> (redirect to zenn)
- fitbit-manager: Fitbit のデータを収集し、API と Influxdb に提供する。
- http-dump: http-test 用。
- kmc-proxy: KMC Server への SSH-Portforward
- \*-oauth2-proxy: 各サービスに OIDC 認証を提供するプロキシ
- machine-status-api: 物理マシンや VM の起動を管理する API
- proxmox-webui, proxmox-backup-webui: Proxmox WebUI へのリバースプロキシ
- wakatime-to-slack-profile: WakaTime のデータを Slack の Status に反映する
