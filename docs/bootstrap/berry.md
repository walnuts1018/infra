# berryの初期セットアップ

## OS設定

Raspberry Pi Imagerを使ってRaspberry Pi OS Lite(64-bit)をインストールする。ユーザーとかIPアドレスとかはいい感じに設定する。

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

## k3sのインストール

```bash
sudo tee /etc/rancher/k3s/config.yaml >/dev/null <<'EOF'
write-kubeconfig-mode: "0644"
disable:
  - servicelb
  - local-storage
  - metrics-server
disable-network-policy: true
flannel-backend: host-gw
EOF
```

```bash
sudo tee /var/lib/rancher/k3s/server/manifests/traefik-config.yaml >/dev/null <<'EOF'
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
EOF
```

```bash
curl -sfL https://get.k3s.io | sh -
```

## root Secretの作成

TODO: opコマンドで取得できるはず

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

## Argo CD導入

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 10.8.2 \
  --kube-context berry --namespace argocd --create-namespace \
  --values k8s/_argocd/argocd_components/values.yaml \
  --values k8s/_argocd/argocd_components/values.berry.yaml
kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
```
