# berry bootstrap

`berry`はRaspberry Pi OS上のmanagement clusterとする。ここで行うのはOS固有設定、ネットワーク、k3s、root Secret、Argo CDの初回導入、base Applicationの投入だけとする。

## 物理とOS

Raspberry Pi ImagerでRaspberry Pi OS Lite 64bitをインストールし、管理用ネットワーク、ホスト名、DHCP予約または固定アドレスを設定する。`/boot/firmware/cmdline.txt`のcgroup設定、`config.txt`の不要なBluetoothとWi-Fiの無効化、watchdog、Timezone`Asia/Tokyo`を設定して再起動する。

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
```

## k3s

`/etc/rancher/k3s/config.yaml`を作成してからk3sをインストールする。berryでは組み込みServiceLB、local-storage、metrics-serverを使用せず、既存のTraefikはGateway APIだけを有効にする。

```yaml
write-kubeconfig-mode: "0644"
disable:
  - servicelb
  - local-storage
  - metrics-server
disable-network-policy: true
flannel-backend: host-gw
```

`/var/lib/rancher/k3s/server/manifests/traefik-config.yaml`を作成し、組み込みTraefikのIngress providerを無効化してGateway providerを有効化する。

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

```bash
curl -sfL https://get.k3s.io | sh -
```

## root Secret

berryの`onepassword` namespaceへ、1Password Connectが最初に読む2つのSecretだけを作成する。次の環境変数はシェルへ直接設定し、ファイルや値をGitへ保存しない。

```bash
: "${ONEPASSWORD_CREDENTIALS_FILE:?set the path to 1password-credentials.json}"
: "${ONEPASSWORD_CONNECT_TOKEN:?set the 1Password Connect token}"

kubectl --context berry create namespace onepassword --dry-run=client -o yaml \
  | kubectl --context berry apply -f -
kubectl --context berry create secret generic op-credentials -n onepassword \
  --from-file=1password-credentials.json="$ONEPASSWORD_CREDENTIALS_FILE" \
  --dry-run=client -o yaml | kubectl --context berry apply -f -
kubectl --context berry create secret generic onepassword-token -n onepassword \
  --from-literal=token="$ONEPASSWORD_CONNECT_TOKEN" \
  --dry-run=client -o yaml | kubectl --context berry apply -f -
```

`argocd-agent-jwt`は手動作成しない。Argo CD Agent用のExternalSecretが、1Passwordの`argocd-agent-jwt`Document itemにある`jwt.key`ファイルをberry上の`argocd-agent-jwt` Secretへ同期する。

## Argo CD

Argo CDを一度だけberryへ導入する。導入後のArgo CD、Principal、証明書、ApplicationSetはbase Applicationが管理する。

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 10.8.2 \
  --kube-context berry --namespace argocd --create-namespace \
  --values k8s/_argocd/argocd_components/values.yaml \
  --values k8s/_argocd/argocd_components/values.berry.yaml
kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
```

最後の`base.yaml`適用後は個別のApplication、Cluster、Secretを手動で適用しない。
