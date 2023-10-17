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

- kurumi-01: Raspberry Pi 4B 2GB
- kurumi-02: Raspberry Pi 4B 4GB
- kurumi-03: Ubuntu22.04 VM 8GB

## 稼働サービス

### システム

- external-dns: Ingress リソースから自動的に外部 DNS サーバーに登録してくれるマン。Cloudflare Tunnel に登録できるように修正を加えています。
- external-secrets: Vault などの外部サービスからデータを読み込み、Secret を作成してくれるマン。
- flannel: CNI です。
- ingress-nginx: Nginx を L7LB として利用した Ingress Controller
- keycloak: OIDC Provider。ユーザー管理と IdP をやってくれる。これ一つで色々なサービスに Single Sign On できる。walnuts.dev を支える認証システム。
