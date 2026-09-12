# berryの初期セットアップ

Raspberry Pi OS上で動作する管理クラスタ(Management Cluster)`berry`の初期セットアップ手順です。

この手順では、OS固有の基本設定、ネットワーク、k3sのインストール、1Password Connect用のroot Secret作成、Argo CDの初回導入、およびベースマニフェスト(`base.yaml`)の適用までを行います。

## 1. OSの初期設定

Raspberry Pi Imagerを使ってRaspberry Pi OS Lite(64-bit)をインストールします。
管理用ネットワーク、ホスト名、固定IP(またはDHCP予約)を設定した後、以下のコマンドでcgroup、ファームウェア更新、不要なインターフェース(Bluetooth/Wi-Fi)の無効化、ハードウェアウォッチドッグ、タイムゾーン(Asia/Tokyo)を設定して再起動します。

```bash
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/firmware/cmdline.txt
sudo rpi-eeprom-update -a
sudo tee -a /boot/firmware/config.txt >/dev/null <<'EOF'
dtoverlay=cma,cma-64
dtoverlay=disable-bt
dtoverlay=disable-wifi
dtparam=watchdog=on
EOF
sudo timedatectl set-timezone Asia/Tokyo
sudo reboot
```

## 2. k3sのインストール

k3sをインストールする前に、設定ファイル`/etc/rancher/k3s/config.yaml`を作成します。
`berry`では組み込みのServiceLB、local-storage、metrics-serverは使用しません。

```yaml
write-kubeconfig-mode: "0644"
disable:
  - servicelb
  - local-storage
  - metrics-server
disable-network-policy: true
flannel-backend: host-gw
```

組み込みのTraefikについては、Ingress providerを無効化し、Gateway API providerのみを有効化します。`/var/lib/rancher/k3s/server/manifests/traefik-config.yaml`を作成してください。

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    providers:
      kubernetesIngress:
        enabled: false
      kubernetesGateway:
        enabled: true
```

設定ファイルを配置後、k3sをインストールします。

```bash
curl -sfL https://get.k3s.io | sh -
```

## 3. root Secretの作成

1Password Connectが起動時に参照する2つのSecretを`onepassword` Namespaceに作成します。
(※シークレットの値や認証ファイルを誤ってGitにコミットしないよう注意してください)

```bash
: "${ONEPASSWORD_CREDENTIALS_FILE:?1password-credentials.jsonへのパスを指定してください}"
: "${ONEPASSWORD_CONNECT_TOKEN:?1Password Connect tokenを指定してください}"


kubectl --context berry create namespace onepassword --dry-run=client -o yaml \
  | kubectl --context berry apply -f -
kubectl --context berry create secret generic op-credentials -n onepassword \
  --from-file=1password-credentials.json="$ONEPASSWORD_CREDENTIALS_FILE" \
  --dry-run=client -o yaml | kubectl --context berry apply -f -
kubectl --context berry create secret generic onepassword-token -n onepassword \
  --from-literal=token="$ONEPASSWORD_CONNECT_TOKEN" \
  --dry-run=client -o yaml | kubectl --context berry apply -f -
```

※`argocd-agent-jwt` Secretの手動作成は不要です。Argo CD Agent用のExternalSecretが、1PasswordのDocumentアイテム`argocd-agent-jwt`(`jwt.key`)から`berry`クラスタへ自動的に同期します。

## 4. Argo CDの初期導入とハンドオフ

Argo CDを初期インストールし、GitOpsのエントリポイントとなる`base.yaml`を適用します。
これ以降のArgo CD自体、Principal、各種証明書、ApplicationSet、および各ワークロードの管理はすべてGitOpsに移譲されます。

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 10.8.2 \
  --kube-context berry --namespace argocd --create-namespace \
  --values k8s/_argocd/argocd_components/values.yaml \
  --values k8s/_argocd/argocd_components/values.berry.yaml
kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
```

`base.yaml`の適用が完了した後は、個別のApplication、Cluster、Secretなどを手動で適用する必要はありません。
