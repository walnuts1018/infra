# Kubernetes

Kubernetesクラスタに適用されるManifest群です。

## ディレクトリ構成

- `_flux`: flux用
  - `<クラスタ名>`
    - `flux-system`: flux用の色々
    - `cluster-kustomization.yaml`: ここからclustersの中身が読まれる
- `apps`: アプリケーションごとのManifest
- `clusters`: クラスタごとにincludeするリソースを指定
  - `<クラスタ名>/kustomization.yaml`: namespaceやappsを必要に応じて読み込む
- `components`: kustomize Component
  - `helm`: helm用の設定テンプレート
  - `image-policy`: fluxcd image automationの設定テンプレート
- `image-update`: image automationのManifest
- `init`: インストールコマンドとインストール時に使うManifest ⇒ [./init/readme.md](./init/readme.md)
- `namespaces`: fluxにより自動作成されるnamespace
- `templates`: すぐに書き方を忘れるmanifestたち...


## クラスタ構成